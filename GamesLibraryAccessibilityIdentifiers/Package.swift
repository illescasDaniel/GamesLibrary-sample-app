// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "GamesLibraryAccessibilityIdentifiers",
	platforms: [.iOS("18.0"), .macOS("14.0")],
	products: [
		.library(name: "AccessibilityIdentifiers", targets: ["AccessibilityIdentifiers"]),
	],
	targets: [
		.target(
			name: "AccessibilityIdentifiers",
			path: "Sources/AccessibilityIdentifiers"
		),
	]
)
