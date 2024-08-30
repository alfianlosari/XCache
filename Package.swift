// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCache",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .visionOS(.v1)],
    products: [
        .library(
            name: "XCache",
            targets: ["XCache"]),
    ],
    targets: [
        .target(
            name: "XCache"),
    ]
)
