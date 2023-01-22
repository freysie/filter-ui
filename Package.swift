// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "filter-ui",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .library(name: "FilterUI", targets: ["FilterUI"]),
    .library(name: "FilterUICore", targets: ["FilterUICore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/freyaariel/previews-capture.git", branch: "main"),
  ],
  targets: [
    .target(name: "FilterUI", dependencies: [
      "FilterUICore",
      .product(name: "PreviewsCapture", package: "previews-capture"),
    ]),
    .target(name: "FilterUICore", dependencies: [])
  ]
)
