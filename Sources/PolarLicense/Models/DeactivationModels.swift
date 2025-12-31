//
//  DeactivationModels.swift
//  PolarLicense
//
//  Request and response models for license key deactivation.
//

import Foundation

// MARK: - Deactivation Request

/// Request body for deactivating a license key activation.
public struct DeactivateRequest: Encodable, Sendable {
    /// The license key to deactivate.
    public let key: String

    /// The organization ID (required by Polar).
    public let organizationId: String

    /// The activation ID to deactivate.
    public let activationId: String

    enum CodingKeys: String, CodingKey {
        case key
        case organizationId = "organization_id"
        case activationId = "activation_id"
    }

    public init(
        key: String,
        organizationId: String,
        activationId: String
    ) {
        self.key = key
        self.organizationId = organizationId
        self.activationId = activationId
    }
}

// MARK: - Deactivation Response

/// Response from the license key deactivation endpoint.
/// A successful deactivation returns HTTP 204 No Content.
public struct DeactivateResponse: Sendable, Equatable {
    /// Whether the deactivation was successful.
    public let deactivated: Bool

    public init(deactivated: Bool = true) {
        self.deactivated = deactivated
    }
}
