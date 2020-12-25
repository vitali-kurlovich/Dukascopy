// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dukascopy",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Dukascopy",
            targets: ["Dukascopy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/vitali-kurlovich/DukascopyDownloader.git", from: "1.0.0"),
        .package(url: "https://github.com/vitali-kurlovich/DukascopyDecoder.git", from: "1.0.3"),

        // https://github.com/vitali-kurlovich/DukascopyDecoder.git
    ],
    targets: [
        .target(
            name: "Dukascopy",
            dependencies: ["DukascopyDownloader", "DukascopyDecoder",
                           .product(name: "Logging", package: "swift-log")]
        ),
        .testTarget(
            name: "DukascopyTests",
            dependencies: ["Dukascopy"]
        ),
    ]
)
