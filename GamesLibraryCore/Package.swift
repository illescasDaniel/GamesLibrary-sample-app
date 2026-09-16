// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "GamesLibraryCore",
	platforms: [.iOS("18.0"), .macOS("14.0")],
	products: [
		.library(name: "GamesLibraryCore", targets: ["GamesLibraryCore"]),
	],
	targets: [
		.target(
			name: "GamesLibraryCore",
			path: "Sources/GamesLibraryCore"
		),
		.testTarget(
			name: "GamesLibraryCoreTests",
			dependencies: ["GamesLibraryCore"],
			path: "Tests/GamesLibraryCoreTests"
		),
	]
)
