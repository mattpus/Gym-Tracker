// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GymTracker",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "WorkoutsDomain", targets: ["WorkoutsDomain"]),
        .library(name: "WorkoutsData", targets: ["WorkoutsData"]),
        .library(name: "WorkoutsPresentation", targets: ["WorkoutsPresentation"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WorkoutsDomain",
            dependencies: []),
        .target(
            name: "WorkoutsData",
            dependencies: ["WorkoutsDomain"],
            resources: [
                .process("Resources")
            ]),
        .target(
            name: "WorkoutsPresentation",
            dependencies: ["WorkoutsDomain"]),
        .testTarget(
            name: "WorkoutsDomainTests",
            dependencies: ["WorkoutsDomain"]),
        .testTarget(
            name: "WorkoutsDataTests",
            dependencies: ["WorkoutsData"]),
        .testTarget(
            name: "WorkoutsPresentationTests",
            dependencies: ["WorkoutsPresentation"])
    ]
)
