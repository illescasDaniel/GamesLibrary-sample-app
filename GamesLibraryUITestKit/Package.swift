// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "GamesLibraryUITestKit",
	platforms: [.iOS("18.0"), .macOS("14.0")],
	products: [
		.library(name: "GamesLibraryUITestKit", targets: ["GamesLibraryUITestKit"]),
	],
	dependencies: [
		.package(path: "../GamesLibraryCore"),
		.package(path: "../GamesLibraryAccessibilityIdentifiers"),
	],
	targets: [
		.target(
			name: "GamesLibraryUITestKit",
			dependencies: [
				"GamesLibraryCore",
				.product(name: "AccessibilityIdentifiers", package: "GamesLibraryAccessibilityIdentifiers"),
			],
			path: "Sources/GamesLibraryUITestKit"
		),
	]
)
