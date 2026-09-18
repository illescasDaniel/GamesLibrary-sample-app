// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "SwiftUIComponents",
	platforms: [.iOS("18.0"), .macOS("15.0")],
	products: [
		.library(name: "SwiftUIComponents", targets: ["SwiftUIComponents"]),
	],
	targets: [
		.target(
			name: "SwiftUIComponents",
			path: "Sources/SwiftUIComponents",
			resources: [.process("Resources")]
		),
	]
)
