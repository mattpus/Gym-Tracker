// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GymTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "WorkoutsDomain", targets: ["WorkoutsDomain"]),
        .library(name: "WorkoutsData", targets: ["WorkoutsData"]),
        .library(name: "WorkoutsPresentation", targets: ["WorkoutsPresentation"]),
        .library(name: "ExerciseLibraryDomain", targets: ["ExerciseLibraryDomain"]),
        .library(name: "ExerciseLibraryData", targets: ["ExerciseLibraryData"]),
        .library(name: "AnalyticsDomain", targets: ["AnalyticsDomain"]),
        .library(name: "AnalyticsData", targets: ["AnalyticsData"]),
        .library(name: "AnalyticsPresentation", targets: ["AnalyticsPresentation"]),
        .library(name: "ProgressionDomain", targets: ["ProgressionDomain"]),
        .library(name: "ProgressionData", targets: ["ProgressionData"])
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
        .target(
            name: "ExerciseLibraryDomain",
            dependencies: []),
        .target(
            name: "ExerciseLibraryData",
            dependencies: ["ExerciseLibraryDomain"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "WorkoutsDomainTests",
            dependencies: ["WorkoutsDomain"]),
        .testTarget(
            name: "WorkoutsDataTests",
            dependencies: ["WorkoutsData"]),
        .testTarget(
            name: "WorkoutsPresentationTests",
            dependencies: ["WorkoutsPresentation"]),
        .testTarget(
            name: "ExerciseLibraryDomainTests",
            dependencies: ["ExerciseLibraryDomain"]),
        .testTarget(
            name: "ExerciseLibraryDataTests",
            dependencies: ["ExerciseLibraryData"]),
        .target(
            name: "AnalyticsDomain",
            dependencies: []),
        .target(
            name: "AnalyticsData",
            dependencies: ["AnalyticsDomain", "WorkoutsDomain", "ExerciseLibraryDomain"]),
        .target(
            name: "AnalyticsPresentation",
            dependencies: ["AnalyticsDomain"]),
        .testTarget(
            name: "AnalyticsDomainTests",
            dependencies: ["AnalyticsDomain"]),
        .testTarget(
            name: "AnalyticsDataTests",
            dependencies: ["AnalyticsData", "WorkoutsDomain"]),
        .target(
            name: "ProgressionDomain",
            dependencies: []),
        .target(
            name: "ProgressionData",
            dependencies: ["ProgressionDomain", "WorkoutsDomain"]),
        .testTarget(
            name: "ProgressionDomainTests",
            dependencies: ["ProgressionDomain"]),
        .testTarget(
            name: "ProgressionDataTests",
            dependencies: ["ProgressionData", "WorkoutsDomain"])
    ]
)
