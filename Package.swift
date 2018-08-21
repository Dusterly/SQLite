// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLite",
    products: [
        .library(
            name: "SQLite",
            targets: ["SQLite"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
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
