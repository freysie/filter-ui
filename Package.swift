// swift-tools-version: 5.6
import PackageDescription

let package = Package(
  name: "filter-ui",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .library(name: "FilterUI", targets: ["FilterUI"]),
    .library(name: "FilterUICore", targets: ["FilterUICore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/krisk/fuse-swift.git", from: "1.4.0"),
    .package(url: "https://github.com/freyaariel/preview-screenshots.git", branch: "main"),
  ],
  targets: [
    .target(name: "FilterUI", dependencies: [
      "FilterUICore",
      .product(name: "Fuse", package: "fuse-swift"),
      .product(name: "PreviewScreenshots", package: "preview-screenshots"),
    ]),
    .target(name: "FilterUICore", dependencies: [])
  ]
)
