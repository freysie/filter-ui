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
    .package(url: "https://github.com/database-utility/fuzzy-search.git", branch: "main"),
  ],
  targets: [
    .target(name: "FilterUI", dependencies: [
      "FilterUIObjC",
      .product(name: "FuzzySearch", package: "fuzzy-search"),
    ]),
    .target(name: "FilterUIObjC", publicHeadersPath: ".")
  ]
)
