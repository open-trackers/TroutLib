// swift-tools-version: 5.7
//

import PackageDescription

let package = Package(name: "TroutLib",
                      platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
                      products: [
                          .library(name: "TroutLib",
                                   targets: ["TroutLib"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
                          .package(url: "https://github.com/open-trackers/TrackerLib.git", from: "1.0.0"),
                          .package(url: "https://github.com/openalloc/SwiftTextFieldPreset.git", from: "1.0.0"),
                      ],
                      targets: [
                          .target(name: "TroutLib",
                                  dependencies: [
                                      .product(name: "Collections", package: "swift-collections"),
                                      .product(name: "TrackerLib", package: "TrackerLib"),
                                      .product(name: "TextFieldPreset", package: "SwiftTextFieldPreset"),
                                  ],
                                  path: "Sources"),
                          .testTarget(name: "TroutLibTests",
                                      dependencies: ["TroutLib"],
                                      path: "Tests"),
                      ])
