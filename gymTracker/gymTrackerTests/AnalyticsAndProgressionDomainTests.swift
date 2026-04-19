import XCTest
@testable import gymTracker

private struct WorkoutDataRepositoryStub: WorkoutDataRepository {
    let workouts: [WorkoutData]

    func loadWorkouts(from startDate: Date?, to endDate: Date?) throws -> [WorkoutData] {
        workouts.filter { workout in
            let afterStart = startDate.map { workout.date >= $0 } ?? true
            let beforeEnd = endDate.map { workout.date <= $0 } ?? true
            return afterStart && beforeEnd
        }
    }
}

private struct ProgressionServiceSpy: ProgressionService {
    let recommendation: ProgressionRecommendation
    var receivedExerciseName: String?

    func calculateRecommendation(for exerciseName: String, history: ExerciseHistoryForProgression, userProfile: UserProfile) -> ProgressionRecommendation {
        recommendation
    }
}

private struct ExerciseHistoryForProgressionLoaderStub: ExerciseHistoryForProgressionLoading {
    let history: ExerciseHistoryForProgression

    func loadHistory(for exerciseName: String, limit: Int) throws -> ExerciseHistoryForProgression {
        history
    }
}

final class AnalyticsAndProgressionDomainTests: XCTestCase {
    func testWorkoutFrequencyCountsTotalAndRecentWorkouts() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let workouts = [
            WorkoutData(id: UUID(), date: now, name: "A", totalVolume: 100, exercises: []),
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -2, to: now)!, name: "B", totalVolume: 150, exercises: []),
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -10, to: now)!, name: "C", totalVolume: 200, exercises: [])
        ]
        let sut = GetWorkoutFrequencyUseCase(repository: WorkoutDataRepositoryStub(workouts: workouts), calendar: calendar)

        let result = try sut.calculate()

        XCTAssertEqual(result.totalWorkouts, 3)
        XCTAssertEqual(result.workoutsThisWeek, 2)
        XCTAssertEqual(result.workoutsThisMonth, 3)
    }

    func testMuscleGroupDistributionAggregatesSetCounts() throws {
        let workout = WorkoutData(
            id: UUID(),
            date: Date(),
            name: "Push",
            totalVolume: 500,
            exercises: [
                ExerciseData(name: "Bench", muscleGroup: "chest", sets: [.init(weight: 60, reps: 8), .init(weight: 60, reps: 8)]),
                ExerciseData(name: "Dip", muscleGroup: "chest", sets: [.init(weight: nil, reps: 12)]),
                ExerciseData(name: "Row", muscleGroup: "back", sets: [.init(weight: 50, reps: 10)])
            ]
        )
        let sut = GetMuscleGroupDistributionUseCase(repository: WorkoutDataRepositoryStub(workouts: [workout]))

        let result = try sut.calculate(days: 30)

        XCTAssertEqual(result.totalSets, 4)
        XCTAssertEqual(result.mostTrainedMuscle, "chest")
        XCTAssertEqual(result.distribution.first(where: { $0.muscleGroup == "chest" })?.setCount, 3)
    }

    func testVolumeProgressionCalculatesIncreasingTrend() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let workouts = [
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -6, to: now)!, name: "A", totalVolume: 100, exercises: []),
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -4, to: now)!, name: "B", totalVolume: 120, exercises: []),
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -2, to: now)!, name: "C", totalVolume: 180, exercises: []),
            WorkoutData(id: UUID(), date: calendar.date(byAdding: .day, value: -1, to: now)!, name: "D", totalVolume: 200, exercises: [])
        ]
        let sut = GetVolumeProgressionUseCase(repository: WorkoutDataRepositoryStub(workouts: workouts), calendar: calendar)

        let result = try sut.calculate(days: 30)

        XCTAssertEqual(result.trend, .increasing)
        XCTAssertEqual(result.dataPoints.count, 4)
        XCTAssertEqual(result.totalVolume, 600)
    }

    func testRecoveryStatusMarksRecentlyTrainedAndRecoveredMuscles() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let workouts = [
            WorkoutData(
                id: UUID(),
                date: now,
                name: "Legs",
                totalVolume: 100,
                exercises: [ExerciseData(name: "Squat", muscleGroup: "quadriceps", sets: [.init(weight: 100, reps: 5)])]
            ),
            WorkoutData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                name: "Pull",
                totalVolume: 100,
                exercises: [ExerciseData(name: "Row", muscleGroup: "back", sets: [.init(weight: 60, reps: 10)])]
            )
        ]
        let sut = GetRecoveryStatusUseCase(repository: WorkoutDataRepositoryStub(workouts: workouts), calendar: calendar)

        let result = try sut.calculate()

        XCTAssertTrue(result.recoveringMuscles.contains("quadriceps"))
        XCTAssertTrue(result.fullyRecoveredMuscles.contains("back"))
    }

    func testWeeklyInsightsSummarizesCurrentWeek() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let workouts = [
            WorkoutData(
                id: UUID(),
                date: now,
                name: "Push",
                totalVolume: 200,
                duration: 3600,
                exercises: [ExerciseData(name: "Bench", muscleGroup: "chest", sets: [.init(weight: 60, reps: 8)])]
            ),
            WorkoutData(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                name: "Pull",
                totalVolume: 300,
                duration: 1800,
                exercises: [ExerciseData(name: "Row", muscleGroup: "back", sets: [.init(weight: 50, reps: 10)])]
            )
        ]
        let sut = GenerateWeeklyInsightsUseCase(repository: WorkoutDataRepositoryStub(workouts: workouts), calendar: calendar)

        let result = try sut.generate()

        XCTAssertEqual(result.workoutCount, 2)
        XCTAssertEqual(result.totalVolume, 500)
        XCTAssertEqual(result.totalDuration, 5400)
        XCTAssertEqual(Set(result.muscleGroupsHit), Set(["chest", "back"]))
    }

    func testProgressionRecommendationDelegatesToService() throws {
        let recommendation = ProgressionRecommendation(
            exerciseName: "Bench Press",
            recommendedWeight: 62.5,
            recommendedReps: 8,
            recommendationType: .increaseWeight,
            reason: "Stable recent performance",
            confidence: .high
        )
        let history = ExerciseHistoryForProgression(
            exerciseName: "Bench Press",
            recentSets: [HistoricalSet(date: Date(), weight: 60, reps: 8)],
            personalRecord: nil
        )
        let sut = GetProgressionRecommendationUseCase(
            historyLoader: ExerciseHistoryForProgressionLoaderStub(history: history),
            progressionService: ProgressionServiceSpy(recommendation: recommendation)
        )

        let result = try sut.getRecommendation(for: "Bench Press")

        XCTAssertEqual(result, recommendation)
    }
}
