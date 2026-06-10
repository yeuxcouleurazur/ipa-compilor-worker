// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v17)],
    products: [
        .executable(name: "MyApp", targets: ["MyApp"])
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            path: ".",
            exclude: ["MyApp.xcodeproj", "Assets.xcassets", "Preview Content", "Info.plist"]
        )
    ]
)
