// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PhantomWallet",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PhantomWallet",
            targets: ["PhantomWallet"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PhantomWallet",
            dependencies: [],
            path: "MyApp"
        )
    ]
)
