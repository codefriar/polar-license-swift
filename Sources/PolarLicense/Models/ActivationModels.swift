//
//  ActivationModels.swift
//  PolarLicense
//
//  Request and response models for license key activation.
//

import Foundation

// MARK: - Activation Request

/// Request body for activating a license key.
public struct ActivateRequest: Encodable, Sendable {
    /// The license key to activate.
    public let key: String

    /// The organization ID (required by Polar).
    public let organizationId: String

    /// A label to identify this activation (e.g., device name).
    public let label: String

    /// Optional conditions for validation matching.
    public let conditions: [String: String]?

    /// Optional metadata to store with the activation.
    public let meta: [String: String]?

    enum CodingKeys: String, CodingKey {
        case key, label, conditions, meta
        case organizationId = "organization_id"
    }

    public init(
        key: String,
        organizationId: String,
        label: String,
        conditions: [String: String]? = nil,
        meta: [String: String]? = nil
    ) {
        self.key = key
        self.organizationId = organizationId
        self.label = label
        self.conditions = conditions
        self.meta = meta
    }
}

// MARK: - Activation Response

/// Response from the license key activation endpoint.
public struct ActivateResponse: Codable, Sendable, Equatable {
    /// Unique activation identifier.
    public let id: String

    /// The license key ID this activation belongs to.
    public let licenseKeyId: String

    /// Label for this activation.
    public let label: String

    /// Custom metadata stored with the activation.
    public let meta: [String: String]?

    /// When this activation was created.
    public let createdAt: Date

    /// When this activation was last modified (nil if never modified).
    public let modifiedAt: Date?

    /// The associated license key information.
    public let licenseKey: PolarLicenseKey

    // Note: No CodingKeys needed - using decoder.keyDecodingStrategy = .convertFromSnakeCase
}
