// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "csv2json",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "csv2json", targets: ["csv2json"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.1"),
        .package(url: "https://github.com/dehesa/CodableCSV", from: "0.6.4"),
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
