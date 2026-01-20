// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcstrings-crud",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "xcstrings-crud", targets: ["xcstrings-crud"]),
        .executable(name: "xcstrings-mcp", targets: ["xcstrings-mcp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk", exact: "0.10.2"),
    ],
    targets: [
        // コアライブラリ（モデル・パーサー）
        .target(name: "XCStringsKit"),

        // CLIコマンド実装
        .target(
            name: "XCStringsCLI",
            dependencies: [
                "XCStringsKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),

        // MCPサーバー実装
        .target(
            name: "XCStringsMCP",
            dependencies: [
                "XCStringsKit",
                .product(name: "MCP", package: "swift-sdk"),
            ]
        ),

        // CLI実行ファイル
        .executableTarget(
            name: "xcstrings-crud",
            dependencies: ["XCStringsCLI"]
        ),

        // MCP実行ファイル
        .executableTarget(
            name: "xcstrings-mcp",
            dependencies: ["XCStringsMCP"]
        ),

        // テスト
        .testTarget(
            name: "XCStringsKitTests",
            dependencies: ["XCStringsKit"]
        ),
    ]
)
