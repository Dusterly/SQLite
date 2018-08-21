// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLite",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SQLite",
            targets: ["SQLite"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Libsqlite3Mac",
            dependencies: []),
        .target(
            name: "Libsqlite3Linux",
            dependencies: []),

        .target(
            name: "SQLite",
            dependencies: ["Libsqlite3Linux", "Libsqlite3Mac"]),
        .testTarget(
            name: "SQLiteTests",
            dependencies: ["SQLite"]),
    ]
)
