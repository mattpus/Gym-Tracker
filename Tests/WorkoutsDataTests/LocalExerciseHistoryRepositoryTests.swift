import XCTest
@testable import WorkoutsData
@testable import WorkoutsDomain

final class LocalExerciseHistoryRepositoryTests: XCTestCase {
    
    func test_loadHistoryForExercise_returnsMatchingRecords() throws {
        let store = MockWorkoutStore(workouts: makeWorkouts())
        let sut = LocalExerciseHistoryRepository(store: store)
        
        let records = try sut.loadHistory(for: "Bench Press")
        
        XCTAssertEqual(records.count, 3)
        XCTAssertTrue(records.allSatisfy { $0.exerciseName == "Bench Press" })
    }
    
    func test_loadHistoryForExercise_returnsEmptyForUnknownExercise() throws {
        let store = MockWorkoutStore(workouts: makeWorkouts())
        let sut = LocalExerciseHistoryRepository(store: store)
        
        let records = try sut.loadHistory(for: "Unknown Exercise")
        
        XCTAssertTrue(records.isEmpty)
    }
    
    func test_loadHistoryWithDateFilter_returnsFilteredRecords() throws {
        let store = MockWorkoutStore(workouts: makeWorkouts())
        let sut = LocalExerciseHistoryRepository(store: store)
        let query = WorkoutHistoryQuery.lastDays(5)
        
        let records = try sut.loadHistory(query: query)
        
        // Only workouts from last 5 days should be included
        XCTAssertTrue(records.allSatisfy { $0.date >= query.startDate! })
    }
    
    func test_loadHistoryWithLimit_returnsLimitedRecords() throws {
        let store = MockWorkoutStore(workouts: makeWorkouts())
        let sut = LocalExerciseHistoryRepository(store: store)
        let query = WorkoutHistoryQuery(limit: 2)
        
        let records = try sut.loadHistory(query: query)
        
        XCTAssertEqual(records.count, 2)
    }
    
    func test_loadAllExerciseNames_returnsUniqueNames() throws {
        let store = MockWorkoutStore(workouts: makeWorkouts())
        let sut = LocalExerciseHistoryRepository(store: store)
        
        let names = try sut.loadAllExerciseNames()
        
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("Bench Press"))
        XCTAssertTrue(names.contains("Squat"))
    }
    
    func test_loadHistory_returnsEmptyWhenNoCache() throws {
        let store = MockWorkoutStore(workouts: nil)
        let sut = LocalExerciseHistoryRepository(store: store)
        
        let records = try sut.loadHistory(for: "Bench Press")
        
        XCTAssertTrue(records.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeWorkouts() -> [LocalWorkout] {
        [
            LocalWorkout(
                id: UUID(),
                date: Date(),
                name: "Push Day",
                notes: nil,
                exercises: [
                    LocalExercise(
                        id: UUID(),
                        name: "Bench Press",
                        notes: nil,
                        sets: [
                            LocalExerciseSet(id: UUID(), order: 1, repetitions: 10, weight: 100, duration: nil),
                            LocalExerciseSet(id: UUID(), order: 2, repetitions: 8, weight: 100, duration: nil)
                        ],
                        supersetID: nil,
                        supersetOrder: nil
                    )
                ]
            ),
            LocalWorkout(
                id: UUID(),
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                name: "Push Day",
                notes: nil,
                exercises: [
                    LocalExercise(
                        id: UUID(),
                        name: "Bench Press",
                        notes: nil,
                        sets: [
                            LocalExerciseSet(id: UUID(), order: 1, repetitions: 10, weight: 95, duration: nil)
                        ],
                        supersetID: nil,
                        supersetOrder: nil
                    ),
                    LocalExercise(
                        id: UUID(),
                        name: "Squat",
                        notes: nil,
                        sets: [
                            LocalExerciseSet(id: UUID(), order: 1, repetitions: 8, weight: 120, duration: nil)
                        ],
                        supersetID: nil,
                        supersetOrder: nil
                    )
                ]
            )
        ]
    }
}

final class MockWorkoutStore: WorkoutStore {
    private let workouts: [LocalWorkout]?
    
    init(workouts: [LocalWorkout]?) {
        self.workouts = workouts
    }
    
    func insert(_ workouts: [LocalWorkout], timestamp: Date) throws {}
    
    func retrieve() throws -> CachedWorkouts? {
        guard let workouts else { return nil }
        return CachedWorkouts(workouts: workouts, timestamp: Date())
    }
    
    func deleteCachedWorkouts() throws {}
}
