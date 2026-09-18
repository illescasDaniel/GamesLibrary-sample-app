// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "XCUITestPOM",
	platforms: [.iOS("18.0"), .macOS("14.0")],
	products: [
		.library(name: "XCUITestPOM", targets: ["XCUITestPOM"]),
	],
	targets: [
		.target(
			name: "XCUITestPOM",
			path: "Sources/XCUITestPOM",
			linkerSettings: [
				.linkedFramework("XCTest"),
			]
		),
	]
)
