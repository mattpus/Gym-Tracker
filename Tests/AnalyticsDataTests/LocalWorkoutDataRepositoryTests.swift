import XCTest
@testable import AnalyticsData
@testable import AnalyticsDomain
@testable import WorkoutsDomain

final class LocalWorkoutDataRepositoryTests: XCTestCase {
    
    func test_loadWorkouts_convertsWorkoutsToWorkoutData() throws {
        let workoutRepo = MockWorkoutRepository(workouts: makeWorkouts())
        let sut = LocalWorkoutDataRepository(workoutRepository: workoutRepo)
        
        let result = try sut.loadWorkouts(from: nil, to: nil)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Test Workout")
    }
    
    func test_loadWorkouts_calculatesTotalVolume() throws {
        let workouts = [
            Workout(
                id: UUID(),
                date: Date(),
                name: "Test",
                exercises: [
                    Exercise(name: "Bench Press", sets: [
                        ExerciseSet(order: 1, repetitions: 10, weight: 100),
                        ExerciseSet(order: 2, repetitions: 8, weight: 100)
                    ])
                ]
            )
        ]
        let workoutRepo = MockWorkoutRepository(workouts: workouts)
        let sut = LocalWorkoutDataRepository(workoutRepository: workoutRepo)
        
        let result = try sut.loadWorkouts(from: nil, to: nil)
        
        XCTAssertEqual(result.first?.totalVolume, 1800) // (10*100) + (8*100)
    }
    
    func test_loadWorkouts_filtersbyDateRange() throws {
        let calendar = Calendar.current
        let today = Date()
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        let workouts = [
            Workout(id: UUID(), date: today, name: "Today", exercises: []),
            Workout(id: UUID(), date: lastWeek, name: "Last Week", exercises: [])
        ]
        let workoutRepo = MockWorkoutRepository(workouts: workouts)
        let sut = LocalWorkoutDataRepository(workoutRepository: workoutRepo)
        
        let startDate = calendar.date(byAdding: .day, value: -3, to: today)!
        let result = try sut.loadWorkouts(from: startDate, to: today)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Today")
    }
    
    func test_loadWorkouts_usesMuscleGroupLookup() throws {
        let workouts = [
            Workout(
                id: UUID(),
                date: Date(),
                name: "Test",
                exercises: [Exercise(name: "Bench Press", sets: [])]
            )
        ]
        let workoutRepo = MockWorkoutRepository(workouts: workouts)
        let lookup = MockMuscleGroupLookup(mappings: ["Bench Press": "chest"])
        let sut = LocalWorkoutDataRepository(workoutRepository: workoutRepo, exerciseLibraryLookup: lookup)
        
        let result = try sut.loadWorkouts(from: nil, to: nil)
        
        XCTAssertEqual(result.first?.exercises.first?.muscleGroup, "chest")
    }
    
    // MARK: - Helpers
    
    private func makeWorkouts() -> [Workout] {
        [
            Workout(
                id: UUID(),
                date: Date(),
                name: "Test Workout",
                exercises: []
            )
        ]
    }
}

final class MockWorkoutRepository: WorkoutRepository {
    private let workouts: [Workout]
    
    init(workouts: [Workout]) {
        self.workouts = workouts
    }
    
    func save(_ workouts: [Workout]) throws {}
    
    func loadWorkouts() throws -> [Workout] {
        workouts
    }
}

final class MockMuscleGroupLookup: ExerciseMuscleGroupLookup {
    private let mappings: [String: String]
    
    init(mappings: [String: String]) {
        self.mappings = mappings
    }
    
    func muscleGroup(for exerciseName: String) -> String? {
        mappings[exerciseName]
    }
}
