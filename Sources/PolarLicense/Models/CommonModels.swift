//
//  CommonModels.swift
//  PolarLicense
//
//  Shared models used across Polar license API responses.
//

import Foundation

// MARK: - License Key Status

/// The status of a Polar license key.
public enum LicenseKeyStatus: String, Codable, Sendable {
    /// License key has been granted and is active.
    case granted
    /// License key has been revoked.
    case revoked
    /// License key has been disabled.
    case disabled
}

// MARK: - Customer

/// Customer information associated with a license key.
public struct PolarCustomer: Codable, Sendable, Equatable {
    /// Unique customer identifier.
    public let id: String

    /// Customer's email address.
    public let email: String

    /// Customer's name.
    public let name: String?

    /// Customer's billing address.
    public let billingAddress: BillingAddress?

    // Note: No CodingKeys needed - using decoder.keyDecodingStrategy = .convertFromSnakeCase
}

/// Customer billing address.
public struct BillingAddress: Codable, Sendable, Equatable {
    public let country: String?
    public let line1: String?
    public let postalCode: String?
    public let city: String?
    public let state: String?

    // Note: No CodingKeys needed - using decoder.keyDecodingStrategy = .convertFromSnakeCase
}

// MARK: - License Key

/// License key information returned by Polar API.
public struct PolarLicenseKey: Codable, Sendable, Equatable {
    /// Unique license key identifier.
    public let id: String

    /// When the license key was created.
    public let createdAt: Date

    /// When the license key was last modified (nil if never modified).
    public let modifiedAt: Date?

    /// Organization ID the license belongs to.
    public let organizationId: String

    /// Customer ID associated with the license.
    public let customerId: String

    /// Benefit ID associated with the license.
    public let benefitId: String

    /// The actual license key string.
    public let key: String

    /// A display-friendly version of the key (partially masked).
    public let displayKey: String

    /// Current status of the license key.
    public let status: LicenseKeyStatus

    /// Maximum number of activations allowed (nil = unlimited).
    public let limitActivations: Int?

    /// Current usage count.
    public let usage: Int

    /// Maximum usage limit (nil = unlimited).
    public let limitUsage: Int?

    /// Number of times the license has been validated.
    public let validations: Int

    /// When the license was last validated.
    public let lastValidatedAt: Date?

    /// When the license expires (nil = never).
    public let expiresAt: Date?

    // Note: No CodingKeys needed - using decoder.keyDecodingStrategy = .convertFromSnakeCase
}

// MARK: - Activation

/// Information about a license key activation instance.
public struct PolarActivation: Codable, Sendable, Equatable {
    /// Unique activation identifier.
    public let id: String

    /// The license key ID this activation belongs to.
    public let licenseKeyId: String

    /// Label/name for this activation (e.g., device name).
    public let label: String

    /// When this activation was created.
    public let createdAt: Date

    /// When this activation was last modified (optional).
    public let modifiedAt: Date?

    /// Custom metadata stored with the activation.
    public let meta: [String: String]?

    // Note: No CodingKeys needed - using decoder.keyDecodingStrategy = .convertFromSnakeCase
}
