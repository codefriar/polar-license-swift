//
//  PolarLicense.swift
//  PolarLicense
//
//  A Swift package for Polar.sh license key validation.
//
//  This package provides a simple API client for validating software licenses
//  using Polar.sh's customer portal endpoints. The endpoints don't require
//  authentication and are safe to use in public clients like desktop apps.
//
//  ## Quick Start
//
//  ```swift
//  import PolarLicense
//
//  let config = PolarLicenseConfiguration(organizationId: "your-org-id")
//  let client = PolarLicenseClient(configuration: config)
//
//  // Activate a license key
//  let activation = try await client.activate(
//      key: "LICENSE-KEY-HERE",
//      label: "John's MacBook Pro"
//  )
//
//  // Store activation.id for future validations
//  print("Activation ID: \(activation.id)")
//
//  // Validate the license
//  let validation = try await client.validate(
//      key: "LICENSE-KEY-HERE",
//      activationId: activation.id
//  )
//
//  if validation.isValid {
//      print("License is valid!")
//  }
//  ```
//

// Re-export all public types for convenience
@_exported import struct Foundation.Date
@_exported import struct Foundation.URL
