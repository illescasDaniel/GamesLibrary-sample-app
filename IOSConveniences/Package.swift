// swift-tools-version: 6.0
import PackageDescription

let package = Package(
	name: "IOSConveniences",
	platforms: [.iOS("18.0"), .macOS("14.0")],
	products: [
		.library(name: "ViewLoadState", targets: ["ViewLoadState"]),
		.library(name: "HTMLText", targets: ["HTMLText"]),
		.library(name: "HTTPConveniences", targets: ["HTTPConveniences"]),
	],
	dependencies: [
		.package(url: "https://github.com/illescasDaniel/HTTIES", from: "2.0.2"),
	],
	targets: [
		.target(
			name: "ViewLoadState",
			path: "Sources/ViewLoadState"
		),
		.target(
			name: "HTMLText",
			path: "Sources/HTMLText"
		),
		.target(
			name: "HTTPConveniences",
			dependencies: [
				.product(name: "HTTIES", package: "HTTIES"),
			],
			path: "Sources/HTTPConveniences"
		),
		.testTarget(
			name: "HTMLTextTests",
			dependencies: ["HTMLText"],
			path: "Tests/HTMLTextTests"
		),
		.testTarget(
			name: "HTTPConveniencesTests",
			dependencies: ["HTTPConveniences"],
			path: "Tests/HTTPConveniencesTests"
		),
	]
)
