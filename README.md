# PolarLicense

A Swift package for [Polar.sh](https://polar.sh) license key validation.

## Overview

PolarLicense provides a simple API client for validating software licenses using Polar.sh's customer portal endpoints. The endpoints don't require authentication and are safe to use in public clients like desktop applications.

## Installation

Add PolarLicense to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/codefriar/polar-license-swift", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies and enter the repository URL.

## Quick Start

```swift
import PolarLicense

// Configure with your Polar organization ID
let config = PolarLicenseConfiguration(organizationId: "your-org-id")
let client = PolarLicenseClient(configuration: config)

// Activate a license key
let activation = try await client.activate(
    key: "LICENSE-KEY-HERE",
    label: "John's MacBook Pro"
)

// Store activation.id for future validations
UserDefaults.standard.set(activation.id, forKey: "activationId")

// Validate the license
let validation = try await client.validate(
    key: "LICENSE-KEY-HERE",
    activationId: activation.id
)

if validation.isValid {
    print("License is valid!")
}

// Deactivate when needed (e.g., user logs out)
try await client.deactivate(
    key: "LICENSE-KEY-HERE",
    activationId: activation.id
)
```

## API Reference

### PolarLicenseConfiguration

```swift
let config = PolarLicenseConfiguration(
    organizationId: "your-org-id",  // Required: Your Polar organization UUID
    useSandbox: false               // Optional: Use sandbox API for testing
)
```

### PolarLicenseClient

#### Activate

Activates a license key and reserves an activation slot.

```swift
let response = try await client.activate(
    key: "LICENSE-KEY",           // The license key
    label: "Device Name",         // Label for this activation
    conditions: ["version": "1"], // Optional: Conditions for validation
    meta: ["os": "macos"]         // Optional: Metadata to store
)
```

#### Validate

Validates a license key and optionally a specific activation.

```swift
let response = try await client.validate(
    key: "LICENSE-KEY",              // The license key
    activationId: "activation-id",   // Optional: Specific activation
    incrementUsage: 1,               // Optional: Increment usage counter
    conditions: ["version": "1"]     // Optional: Conditions to check
)

// Check validity
if response.isValid {
    // License is granted and not expired
}

if response.isExpired {
    // License has expired
}
```

#### Deactivate

Deactivates a license key activation, freeing up a slot.

```swift
let response = try await client.deactivate(
    key: "LICENSE-KEY",
    activationId: "activation-id"
)
```

## Error Handling

```swift
do {
    let response = try await client.validate(key: key, activationId: activationId)
} catch let error as PolarLicenseError {
    switch error {
    case .notFound:
        print("License key not found")
    case .rateLimited:
        print("Too many requests")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## License Status

Polar license keys can have these statuses:

- `.granted` - License is active and valid
- `.revoked` - License has been revoked
- `.disabled` - License has been disabled

## Sandbox Testing

For development and testing, use the sandbox API:

```swift
let config = PolarLicenseConfiguration(
    organizationId: "your-org-id",
    useSandbox: true  // Uses sandbox-api.polar.sh
)
```

## Requirements

- Swift 5.9+
- macOS 14+, iOS 17+, tvOS 17+, watchOS 10+

## License

MIT License. See [LICENSE](LICENSE) for details.
