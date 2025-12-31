//
//  ValidationModels.swift
//  PolarLicense
//
//  Request and response models for license key validation.
//

import Foundation

// MARK: - Validation Request

/// Request body for validating a license key.
public struct ValidateRequest: Encodable, Sendable {
    /// The license key to validate.
    public let key: String

    /// The organization ID (required by Polar).
    public let organizationId: String

    /// Optional activation ID for activation-specific validation.
    public let activationId: String?

    /// Optional benefit ID to validate against.
    public let benefitId: String?

    /// Optional customer ID to validate against.
    public let customerId: String?

    /// Optional amount to increment the usage counter.
    public let incrementUsage: Int?

    /// Optional conditions to validate against.
    public let conditions: [String: String]?

    enum CodingKeys: String, CodingKey {
        case key, conditions
        case organizationId = "organization_id"
        case activationId = "activation_id"
        case benefitId = "benefit_id"
        case customerId = "customer_id"
        case incrementUsage = "increment_usage"
    }

    public init(
        key: String,
        organizationId: String,
        activationId: String? = nil,
        benefitId: String? = nil,
        customerId: String? = nil,
        incrementUsage: Int? = nil,
        conditions: [String: String]? = nil
    ) {
        self.key = key
        self.organizationId = organizationId
        self.activationId = activationId
        self.benefitId = benefitId
        self.customerId = customerId
        self.incrementUsage = incrementUsage
        self.conditions = conditions
    }
}

// MARK: - Validation Response

/// Response from the license key validation endpoint.
public struct ValidateResponse: Codable, Sendable, Equatable {
    /// Unique license key identifier.
    public let id: String

    /// When the license key was created.
    public let createdAt: Date

    /// When the license key was last modified.
    public let modifiedAt: Date

    /// Organization ID the license belongs to.
    public let organizationId: String

    /// Customer ID associated with the license.
    public let customerId: String

    /// Customer information.
    public let customer: PolarCustomer?

    /// Benefit ID associated with the license.
    public let benefitId: String

    /// The actual license key string.
    public let key: String

    /// A display-friendly version of the key.
    public let displayKey: String

    /// Current status of the license key.
    public let status: LicenseKeyStatus

    /// Maximum number of activations allowed.
    public let limitActivations: Int?

    /// Current usage count.
    public let usage: Int

    /// Maximum usage limit.
    public let limitUsage: Int?

    /// Number of times the license has been validated.
    public let validations: Int

    /// When the license was last validated.
    public let lastValidatedAt: Date?

    /// When the license expires.
    public let expiresAt: Date?

    /// The activation that was validated (if activation_id was provided).
    public let activation: PolarActivation?

    enum CodingKeys: String, CodingKey {
        case id, key, status, usage, validations, customer, activation
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case organizationId = "organization_id"
        case customerId = "customer_id"
        case benefitId = "benefit_id"
        case displayKey = "display_key"
        case limitActivations = "limit_activations"
        case limitUsage = "limit_usage"
        case lastValidatedAt = "last_validated_at"
        case expiresAt = "expires_at"
    }

    /// Whether the license is currently valid (granted and not expired).
    public var isValid: Bool {
        guard status == .granted else { return false }
        if let expiresAt = expiresAt {
            return Date() < expiresAt
        }
        return true
    }

    /// Whether the license has expired.
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() >= expiresAt
    }
}
