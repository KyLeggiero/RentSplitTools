// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RentSplitTools",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RentSplitTools",
            targets: ["RentSplitTools"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/RougeWare/AppUniqueIdentifier.git", from: "1.0.0"),
        .package(url: "https://github.com/RougeWare/Swift-Basic-Math-Tools.git", from: "1.1.1"),
        .package(url: "https://github.com/RougeWare/Swift-MultiplicativeArithmetic.git", from: "1.3.0"),
        .package(url: "https://github.com/RougeWare/Swift-Simple-Logging.git", from: "0.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RentSplitTools",
            dependencies: [
                "AppUniqueIdentifier",
                .product(name: "BasicMathTools", package: "Swift-Basic-Math-Tools"),
                .product(name: "MultiplicativeArithmetic", package: "Swift-MultiplicativeArithmetic"),
                .product(name: "SimpleLogging", package: "Swift-Simple-Logging"),
            ]),
        .testTarget(
            name: "RentSplitToolsTests",
            dependencies: ["RentSplitTools"]),
    ]
)
