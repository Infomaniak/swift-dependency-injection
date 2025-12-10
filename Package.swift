// swift-tools-version: 5.9
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
