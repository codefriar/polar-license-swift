//
//  PolarLicenseClientTests.swift
//  PolarLicenseTests
//
//  Tests for the PolarLicenseClient.
//

import XCTest
@testable import PolarLicense

final class PolarLicenseClientTests: XCTestCase {
    // MARK: - Configuration Tests

    func testConfigurationProductionURL() {
        let config = PolarLicenseConfiguration(organizationId: "test-org-id")
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.polar.sh/v1")
        XCTAssertFalse(config.useSandbox)
    }

    func testConfigurationSandboxURL() {
        let config = PolarLicenseConfiguration(organizationId: "test-org-id", useSandbox: true)
        XCTAssertEqual(config.baseURL.absoluteString, "https://sandbox-api.polar.sh/v1")
        XCTAssertTrue(config.useSandbox)
    }

    // MARK: - Model Decoding Tests

    func testActivateResponseDecoding() throws {
        let json = """
        {
            "id": "activation-123",
            "license_key_id": "license-456",
            "label": "Test Device",
            "meta": {"device_type": "desktop"},
            "created_at": "2024-01-15T10:30:00Z",
            "modified_at": "2024-01-15T10:30:00Z",
            "license_key": {
                "id": "license-456",
                "created_at": "2024-01-01T00:00:00Z",
                "modified_at": "2024-01-15T10:30:00Z",
                "organization_id": "org-789",
                "customer_id": "customer-111",
                "benefit_id": "benefit-222",
                "key": "XXXX-YYYY-ZZZZ",
                "display_key": "XXXX-****-****",
                "status": "granted",
                "limit_activations": 3,
                "usage": 0,
                "limit_usage": null,
                "validations": 0,
                "last_validated_at": null,
                "expires_at": null
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(ActivateResponse.self, from: json)

        XCTAssertEqual(response.id, "activation-123")
        XCTAssertEqual(response.licenseKeyId, "license-456")
        XCTAssertEqual(response.label, "Test Device")
        XCTAssertEqual(response.meta?["device_type"], "desktop")
        XCTAssertEqual(response.licenseKey.status, .granted)
        XCTAssertEqual(response.licenseKey.limitActivations, 3)
    }

    func testValidateResponseDecoding() throws {
        let json = """
        {
            "id": "license-456",
            "created_at": "2024-01-01T00:00:00Z",
            "modified_at": "2024-01-15T10:30:00Z",
            "organization_id": "org-789",
            "customer_id": "customer-111",
            "customer": {
                "id": "customer-111",
                "email": "test@example.com",
                "name": "Test User",
                "billing_address": null
            },
            "benefit_id": "benefit-222",
            "key": "XXXX-YYYY-ZZZZ",
            "display_key": "XXXX-****-****",
            "status": "granted",
            "limit_activations": 3,
            "usage": 5,
            "limit_usage": 100,
            "validations": 10,
            "last_validated_at": "2024-01-15T10:30:00Z",
            "expires_at": null,
            "activation": {
                "id": "activation-123",
                "license_key_id": "license-456",
                "label": "Test Device",
                "created_at": "2024-01-15T10:30:00Z",
                "modified_at": null,
                "meta": null
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(ValidateResponse.self, from: json)

        XCTAssertEqual(response.id, "license-456")
        XCTAssertEqual(response.status, .granted)
        XCTAssertEqual(response.customer?.email, "test@example.com")
        XCTAssertEqual(response.customer?.name, "Test User")
        XCTAssertEqual(response.usage, 5)
        XCTAssertEqual(response.limitUsage, 100)
        XCTAssertEqual(response.validations, 10)
        XCTAssertNotNil(response.activation)
        XCTAssertEqual(response.activation?.id, "activation-123")
        XCTAssertTrue(response.isValid)
        XCTAssertFalse(response.isExpired)
    }

    func testValidateResponseExpired() throws {
        let json = """
        {
            "id": "license-456",
            "created_at": "2024-01-01T00:00:00Z",
            "modified_at": "2024-01-15T10:30:00Z",
            "organization_id": "org-789",
            "customer_id": "customer-111",
            "customer": null,
            "benefit_id": "benefit-222",
            "key": "XXXX-YYYY-ZZZZ",
            "display_key": "XXXX-****-****",
            "status": "granted",
            "limit_activations": null,
            "usage": 0,
            "limit_usage": null,
            "validations": 1,
            "last_validated_at": "2024-01-15T10:30:00Z",
            "expires_at": "2020-01-01T00:00:00Z",
            "activation": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(ValidateResponse.self, from: json)

        XCTAssertTrue(response.isExpired)
        XCTAssertFalse(response.isValid)
    }

    func testValidateResponseRevoked() throws {
        let json = """
        {
            "id": "license-456",
            "created_at": "2024-01-01T00:00:00Z",
            "modified_at": "2024-01-15T10:30:00Z",
            "organization_id": "org-789",
            "customer_id": "customer-111",
            "customer": null,
            "benefit_id": "benefit-222",
            "key": "XXXX-YYYY-ZZZZ",
            "display_key": "XXXX-****-****",
            "status": "revoked",
            "limit_activations": null,
            "usage": 0,
            "limit_usage": null,
            "validations": 1,
            "last_validated_at": "2024-01-15T10:30:00Z",
            "expires_at": null,
            "activation": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(ValidateResponse.self, from: json)

        XCTAssertEqual(response.status, .revoked)
        XCTAssertFalse(response.isValid)
    }

    func testLicenseKeyStatusDecoding() throws {
        XCTAssertEqual(try decodeStatus("granted"), .granted)
        XCTAssertEqual(try decodeStatus("revoked"), .revoked)
        XCTAssertEqual(try decodeStatus("disabled"), .disabled)
    }

    private func decodeStatus(_ status: String) throws -> LicenseKeyStatus {
        let json = "\"\(status)\"".data(using: .utf8)!
        return try JSONDecoder().decode(LicenseKeyStatus.self, from: json)
    }

    // MARK: - Request Encoding Tests

    func testActivateRequestEncoding() throws {
        let request = ActivateRequest(
            key: "TEST-KEY",
            organizationId: "org-123",
            label: "My Device",
            conditions: ["version": "1.0"],
            meta: ["platform": "macos"]
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["key"] as? String, "TEST-KEY")
        XCTAssertEqual(json["organization_id"] as? String, "org-123")
        XCTAssertEqual(json["label"] as? String, "My Device")
        XCTAssertEqual((json["conditions"] as? [String: String])?["version"], "1.0")
        XCTAssertEqual((json["meta"] as? [String: String])?["platform"], "macos")
    }

    func testValidateRequestEncoding() throws {
        let request = ValidateRequest(
            key: "TEST-KEY",
            organizationId: "org-123",
            activationId: "activation-456",
            incrementUsage: 1
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["key"] as? String, "TEST-KEY")
        XCTAssertEqual(json["organization_id"] as? String, "org-123")
        XCTAssertEqual(json["activation_id"] as? String, "activation-456")
        XCTAssertEqual(json["increment_usage"] as? Int, 1)
    }

    func testDeactivateRequestEncoding() throws {
        let request = DeactivateRequest(
            key: "TEST-KEY",
            organizationId: "org-123",
            activationId: "activation-456"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["key"] as? String, "TEST-KEY")
        XCTAssertEqual(json["organization_id"] as? String, "org-123")
        XCTAssertEqual(json["activation_id"] as? String, "activation-456")
    }

    // MARK: - Error Tests

    func testErrorDescriptions() {
        XCTAssertNotNil(PolarLicenseError.invalidURL.errorDescription)
        XCTAssertNotNil(PolarLicenseError.networkError(URLError(.timedOut)).errorDescription)
        XCTAssertNotNil(PolarLicenseError.invalidResponse.errorDescription)
        XCTAssertNotNil(PolarLicenseError.httpError(statusCode: 500, message: "Server Error").errorDescription)
        XCTAssertNotNil(PolarLicenseError.activationFailed("Test").errorDescription)
        XCTAssertNotNil(PolarLicenseError.validationFailed("Test").errorDescription)
        XCTAssertNotNil(PolarLicenseError.deactivationFailed("Test").errorDescription)
        XCTAssertNotNil(PolarLicenseError.notFound.errorDescription)
        XCTAssertNotNil(PolarLicenseError.rateLimited.errorDescription)
        XCTAssertNotNil(PolarLicenseError.unprocessableEntity("Test").errorDescription)
    }
}
