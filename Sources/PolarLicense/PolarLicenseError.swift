//
//  PolarLicenseError.swift
//  PolarLicense
//
//  Errors that can occur during Polar license operations.
//

import Foundation

/// Errors that can occur during Polar license operations.
public enum PolarLicenseError: LocalizedError {
    /// The API URL could not be constructed.
    case invalidURL

    /// A network error occurred.
    case networkError(Error)

    /// The server returned an invalid response.
    case invalidResponse

    /// The server returned an error status code.
    case httpError(statusCode: Int, message: String?)

    /// License key activation failed.
    case activationFailed(String)

    /// License key validation failed.
    case validationFailed(String)

    /// License key deactivation failed.
    case deactivationFailed(String)

    /// The license key was not found.
    case notFound

    /// The request was rate limited.
    case rateLimited

    /// The request contained invalid data.
    case unprocessableEntity(String)

    /// The license key has reached its activation limit.
    case activationLimitReached

    /// The license key is disabled or revoked.
    case licenseDisabled(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            if let message = message {
                return "HTTP \(statusCode): \(message)"
            }
            return "HTTP error: \(statusCode)"
        case .activationFailed(let message):
            return "Activation failed: \(message)"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .deactivationFailed(let message):
            return "Deactivation failed: \(message)"
        case .notFound:
            return "License key not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .unprocessableEntity(let message):
            return "Invalid request: \(message)"
        case .activationLimitReached:
            return "This license key has reached its maximum number of activations. Please deactivate another device or contact support."
        case .licenseDisabled(let reason):
            return "This license key has been disabled: \(reason)"
        }
    }
}
