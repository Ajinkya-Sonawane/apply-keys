// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ApplyKeysCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ApplyKeysCore", targets: ["ApplyKeysCore"]),
    ],
    targets: [
        .target(name: "ApplyKeysCore"),
        .testTarget(name: "ApplyKeysCoreTests", dependencies: ["ApplyKeysCore"]),
    ]
)
