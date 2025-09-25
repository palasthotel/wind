// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Wind",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
		.macCatalyst(.v17)
	],
	products: [
		.library(name: "Wind", targets: ["Wind"]),
	],
	targets: [
		.target(name: "Wind"),
		.testTarget(name: "WindTests", dependencies: ["Wind"])
	]
)

