// swift-tools-version:5.10
//
// To build with auto-linking of the .swiftmodule use:
// $ swift build -Xswiftc -module-link-name -Xswiftc XCTest
//

import PackageDescription

let package = Package(
    name: "XCTest",
    products: [
        .library(
            name: "XCTest",
            type: .static,
            targets: ["XCTest"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-corelibs-foundation",
            branch: "package"
        ),
    ],
    targets: [
        .target(name: "XCTest", 
            dependencies: [
                .product(name: "Foundation", package: "swift-corelibs-foundation"),
            ], 
            path: "Sources"
        ),
    ]
)
