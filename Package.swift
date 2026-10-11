// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UIComponentsKit",
    platforms: [.iOS("16.6"), .macOS(.v14)],
    products: [.library(name: "UIComponentsKit", targets: ["UIComponentsKit"])],
    dependencies: [.package(url: "https://github.com/Anurag-Chourasia/DesignTokensKit.git", exact: "1.0.0")],
    targets: [
        .target(name: "UIComponentsKit", dependencies: [.product(name: "DesignTokensKit", package: "DesignTokensKit")]),
        .testTarget(name: "UIComponentsKitTests", dependencies: ["UIComponentsKit", .product(name: "DesignTokensKit", package: "DesignTokensKit")])
    ]
)
