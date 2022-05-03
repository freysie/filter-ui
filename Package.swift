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
    
  ],
  targets: [
    .target(name: "FilterUI", dependencies: ["FilterUICore"]),
    .target(name: "FilterUICore", dependencies: [])
  ]
)
