//
//  PolarLicenseClient.swift
//  PolarLicense
//
//  API client for Polar.sh license key validation.
//  Handles license activation, validation, and deactivation.
//

import Foundation

// MARK: - Configuration

/// Configuration for the Polar license client.
public struct PolarLicenseConfiguration: Sendable {
    /// Your Polar organization ID (UUID).
    public let organizationId: String

    /// Whether to use the sandbox API (for testing).
    public let useSandbox: Bool

    /// The base URL for the API.
    public var baseURL: URL {
        if useSandbox {
            return URL(string: "https://sandbox-api.polar.sh/v1")!
        }
        return URL(string: "https://api.polar.sh/v1")!
    }

    public init(organizationId: String, useSandbox: Bool = false) {
        self.organizationId = organizationId
        self.useSandbox = useSandbox
    }
}

// MARK: - Polar License Client

/// Client for interacting with the Polar.sh License API.
///
/// This actor handles all API communication for license operations.
/// The customer portal endpoints don't require authentication and are
/// safe to use in public clients like desktop applications.
///
/// ## Example Usage
///
/// ```swift
/// let config = PolarLicenseConfiguration(organizationId: "your-org-id")
/// let client = PolarLicenseClient(configuration: config)
///
/// // Activate a license
/// let activation = try await client.activate(
///     key: "LICENSE-KEY",
///     label: "John's MacBook Pro"
/// )
///
/// // Validate later
/// let validation = try await client.validate(
///     key: "LICENSE-KEY",
///     activationId: activation.id
/// )
///
/// // Deactivate when needed
/// try await client.deactivate(
///     key: "LICENSE-KEY",
///     activationId: activation.id
/// )
/// ```
public actor PolarLicenseClient {
    /// The client configuration.
    public let configuration: PolarLicenseConfiguration

    /// The URL session used for requests.
    private let session: URLSession

    /// JSON encoder configured for Polar API.
    private let encoder: JSONEncoder

    /// JSON decoder configured for Polar API.
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Creates a new Polar license client.
    /// - Parameters:
    ///   - configuration: The client configuration.
    ///   - session: Optional custom URL session. Defaults to shared session.
    public init(
        configuration: PolarLicenseConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session

        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public API

    /// Activates a license key for this machine.
    ///
    /// This reserves an activation slot for the specified device and returns
    /// a unique activation ID that should be stored and used for future validations.
    ///
    /// - Parameters:
    ///   - key: The license key to activate.
    ///   - label: A label to identify this activation (e.g., device name).
    ///   - conditions: Optional conditions for validation matching.
    ///   - meta: Optional metadata to store with the activation.
    /// - Returns: The activation response containing the activation ID and license info.
    /// - Throws: `PolarLicenseError` if activation fails.
    public func activate(
        key: String,
        label: String,
        conditions: [String: String]? = nil,
        meta: [String: String]? = nil
    ) async throws -> ActivateResponse {
        let request = ActivateRequest(
            key: key,
            organizationId: configuration.organizationId,
            label: label,
            conditions: conditions,
            meta: meta
        )

        let url = configuration.baseURL.appendingPathComponent("customer-portal/license-keys/activate")
        return try await performRequest(url: url, body: request)
    }

    /// Validates an existing license key.
    ///
    /// Use this to verify that a license key is still valid. If you have an
    /// activation ID, include it for additional validation.
    ///
    /// - Parameters:
    ///   - key: The license key to validate.
    ///   - activationId: Optional activation ID for activation-specific validation.
    ///   - incrementUsage: Optional amount to increment the usage counter.
    ///   - conditions: Optional conditions to validate against.
    /// - Returns: The validation response with license status and details.
    /// - Throws: `PolarLicenseError` if validation fails.
    public func validate(
        key: String,
        activationId: String? = nil,
        incrementUsage: Int? = nil,
        conditions: [String: String]? = nil
    ) async throws -> ValidateResponse {
        let request = ValidateRequest(
            key: key,
            organizationId: configuration.organizationId,
            activationId: activationId,
            incrementUsage: incrementUsage,
            conditions: conditions
        )

        let url = configuration.baseURL.appendingPathComponent("customer-portal/license-keys/validate")
        return try await performRequest(url: url, body: request)
    }

    /// Deactivates a license key activation.
    ///
    /// This frees up an activation slot, allowing the license to be activated
    /// on another device.
    ///
    /// - Parameters:
    ///   - key: The license key to deactivate.
    ///   - activationId: The activation ID to deactivate.
    /// - Returns: The deactivation response.
    /// - Throws: `PolarLicenseError` if deactivation fails.
    public func deactivate(
        key: String,
        activationId: String
    ) async throws -> DeactivateResponse {
        let request = DeactivateRequest(
            key: key,
            organizationId: configuration.organizationId,
            activationId: activationId
        )

        let url = configuration.baseURL.appendingPathComponent("customer-portal/license-keys/deactivate")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(request)

        let (_, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PolarLicenseError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200, 204:
            return DeactivateResponse(deactivated: true)
        case 403:
            throw PolarLicenseError.deactivationFailed("Forbidden")
        case 404:
            throw PolarLicenseError.notFound
        case 422:
            throw PolarLicenseError.unprocessableEntity("Invalid request data")
        case 429:
            throw PolarLicenseError.rateLimited
        default:
            throw PolarLicenseError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }
    }

    // MARK: - Private Helpers

    /// Performs a POST request and decodes the response.
    private func performRequest<Request: Encodable, Response: Decodable>(
        url: URL,
        body: Request
    ) async throws -> Response {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw PolarLicenseError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PolarLicenseError.invalidResponse
        }

        // Debug logging
        print("🔑 [PolarClient] Response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔑 [PolarClient] Response body: \(responseString)")
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                print("🔑 [PolarClient] Decoding error: \(error)")
                throw PolarLicenseError.invalidResponse
            }
        case 403:
            // Try to extract error detail from response
            if let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                // Check for specific error types
                if errorBody.error == "NotPermitted" {
                    // Check if it's an activation limit error
                    if let detail = errorBody.detail?.lowercased(),
                       detail.contains("activation limit") || detail.contains("activations") {
                        throw PolarLicenseError.activationLimitReached
                    }
                    // Other permission errors (disabled, revoked, etc.)
                    throw PolarLicenseError.licenseDisabled(errorBody.detail ?? "License key is not permitted")
                }
                throw PolarLicenseError.httpError(statusCode: 403, message: errorBody.detail ?? "Forbidden")
            }
            throw PolarLicenseError.httpError(statusCode: 403, message: "Forbidden")
        case 404:
            throw PolarLicenseError.notFound
        case 422:
            // Try to extract error message from response
            if let errorBody = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw PolarLicenseError.unprocessableEntity(errorBody.detail ?? "Validation error")
            }
            throw PolarLicenseError.unprocessableEntity("Invalid request data")
        case 429:
            throw PolarLicenseError.rateLimited
        default:
            throw PolarLicenseError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }
    }
}

// MARK: - Error Response

/// Error response from Polar API.
private struct ErrorResponse: Decodable {
    /// The error type (e.g., "NotPermitted", "ResourceNotFound").
    let error: String?
    /// The detailed error message.
    let detail: String?
}
