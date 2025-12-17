// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_stripe_connect",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-stripe-connect", targets: ["flutter_stripe_connect"])
    ],
    dependencies: [
        .package(url: "https://github.com/stripe/stripe-ios-spm", from: "24.0.0")
    ],
    targets: [
        .target(
            name: "flutter_stripe_connect",
            dependencies: [
                .product(name: "StripeConnect", package: "stripe-ios-spm")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
