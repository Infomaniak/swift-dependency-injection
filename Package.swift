// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfomaniakDI",
    products: [
        .library(
            name: "InfomaniakDI",
            targets: ["InfomaniakDI"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "InfomaniakDI",
            dependencies: []),
        .testTarget(
            name: "InfomaniakDITests",
            dependencies: ["InfomaniakDI"]),
    ]
)
