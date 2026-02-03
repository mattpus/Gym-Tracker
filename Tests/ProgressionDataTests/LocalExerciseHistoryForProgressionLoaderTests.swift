import XCTest
@testable import ProgressionData
@testable import ProgressionDomain
@testable import WorkoutsDomain

final class LocalExerciseHistoryForProgressionLoaderTests: XCTestCase {
    
    func test_loadHistory_convertsRecordsToHistoricalSets() throws {
        let records = [
            ExercisePerformanceRecord(date: Date(), workoutId: UUID(), exerciseName: "Bench Press", setNumber: 1, weight: 100, repetitions: 10),
            ExercisePerformanceRecord(date: Date(), workoutId: UUID(), exerciseName: "Bench Press", setNumber: 2, weight: 100, repetitions: 8)
        ]
        let repository = MockExerciseHistoryRepository(records: records)
        let sut = LocalExerciseHistoryForProgressionLoader(historyRepository: repository)
        
        let result = try sut.loadHistory(for: "Bench Press", limit: 10)
        
        XCTAssertEqual(result.recentSets.count, 2)
        XCTAssertEqual(result.recentSets.first?.weight, 100)
    }
    
    func test_loadHistory_calculatesPersonalRecord() throws {
        let records = [
            ExercisePerformanceRecord(date: Date(), workoutId: UUID(), exerciseName: "Bench Press", setNumber: 1, weight: 100, repetitions: 10),
            ExercisePerformanceRecord(date: Date(), workoutId: UUID(), exerciseName: "Bench Press", setNumber: 2, weight: 120, repetitions: 6)
        ]
        let repository = MockExerciseHistoryRepository(records: records)
        let sut = LocalExerciseHistoryForProgressionLoader(historyRepository: repository)
        
        let result = try sut.loadHistory(for: "Bench Press", limit: 10)
        
        XCTAssertEqual(result.personalRecord?.maxWeight, 120)
        XCTAssertEqual(result.personalRecord?.maxWeightReps, 6)
    }
    
    func test_loadHistory_respectsLimit() throws {
        let records = (0..<20).map { i in
            ExercisePerformanceRecord(
                date: Date().addingTimeInterval(Double(-i * 86400)),
                workoutId: UUID(),
                exerciseName: "Bench Press",
                setNumber: 1,
                weight: 100,
                repetitions: 10
            )
        }
        let repository = MockExerciseHistoryRepository(records: records)
        let sut = LocalExerciseHistoryForProgressionLoader(historyRepository: repository)
        
        let result = try sut.loadHistory(for: "Bench Press", limit: 5)
        
        XCTAssertEqual(result.recentSets.count, 5)
    }
    
    func test_loadHistory_sortsRecordsByDateDescending() throws {
        let oldDate = Date().addingTimeInterval(-86400 * 7)
        let newDate = Date()
        let records = [
            ExercisePerformanceRecord(date: oldDate, workoutId: UUID(), exerciseName: "Bench Press", setNumber: 1, weight: 90, repetitions: 10),
            ExercisePerformanceRecord(date: newDate, workoutId: UUID(), exerciseName: "Bench Press", setNumber: 1, weight: 100, repetitions: 10)
        ]
        let repository = MockExerciseHistoryRepository(records: records)
        let sut = LocalExerciseHistoryForProgressionLoader(historyRepository: repository)
        
        let result = try sut.loadHistory(for: "Bench Press", limit: 10)
        
        XCTAssertEqual(result.recentSets.first?.weight, 100) // Most recent first
    }
}

final class MockExerciseHistoryRepository: ExerciseHistoryRepository {
    private let records: [ExercisePerformanceRecord]
    
    init(records: [ExercisePerformanceRecord]) {
        self.records = records
    }
    
    func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord] {
        records.filter { $0.exerciseName == exerciseName }
    }
    
    func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord] {
        records
    }
    
    func loadAllExerciseNames() throws -> [String] {
        Array(Set(records.map(\.exerciseName)))
    }
}
