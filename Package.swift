// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "csv2json",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.5"),
        .package(url: "https://github.com/dehesa/CodableCSV", from: "0.5.4"),
    ],
    targets: [
        .target(
            name: "csv2json",
            dependencies: [
                .product(name: "CodableCSV", package: "CodableCSV"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "csv2jsonTests",
            dependencies: ["csv2json"]
        ),
    ]
)
