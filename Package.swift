// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ACKImagePicker",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "ACKImagePicker", targets: ["ACKImagePicker"]),
    ],
    targets: [
        .target(name: "ACKImagePicker", path: "ACKImagePicker"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
