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
  ],
  dependencies: [
    .package(url: "https://github.com/MxIris-Library-Forks/fuzzy-search", from: "0.1.0"),
  ],
  targets: [
    .target(name: "FilterUI", dependencies: [
      "FilterUIObjC",
      .product(name: "FuzzySearch", package: "fuzzy-search"),
    ]),
    .target(name: "FilterUIObjC", publicHeadersPath: ".")
  ]
)
