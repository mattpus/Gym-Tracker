import XCTest
@testable import WorkoutsDomain

final class LoadExerciseHistoryUseCaseTests: XCTestCase {
    
    func test_loadHistoryForExercise_returnsRecordsFromRepository() throws {
        let expectedRecords = makeRecords()
        let repository = MockExerciseHistoryRepository(records: expectedRecords)
        let sut = LoadExerciseHistoryUseCase(repository: repository)
        
        let result = try sut.loadHistory(for: "Bench Press")
        
        XCTAssertEqual(result, expectedRecords)
    }
    
    func test_loadHistoryWithQuery_passesQueryToRepository() throws {
        let repository = MockExerciseHistoryRepository(records: [])
        let sut = LoadExerciseHistoryUseCase(repository: repository)
        let query = WorkoutHistoryQuery.lastDays(30)
        
        _ = try sut.loadHistory(query: query)
        
        XCTAssertEqual(repository.lastQuery, query)
    }
    
    func test_loadHistory_throwsErrorWhenRepositoryFails() {
        let repository = MockExerciseHistoryRepository(error: NSError(domain: "test", code: 1))
        let sut = LoadExerciseHistoryUseCase(repository: repository)
        
        XCTAssertThrowsError(try sut.loadHistory(for: "Bench Press"))
    }
    
    // MARK: - Helpers
    
    private func makeRecords() -> [ExercisePerformanceRecord] {
        [
            ExercisePerformanceRecord(
                date: Date(),
                workoutId: UUID(),
                exerciseName: "Bench Press",
                setNumber: 1,
                weight: 100,
                repetitions: 10
            )
        ]
    }
}

final class MockExerciseHistoryRepository: ExerciseHistoryRepository {
    private let records: [ExercisePerformanceRecord]
    private let error: Error?
    private(set) var lastQuery: WorkoutHistoryQuery?
    
    init(records: [ExercisePerformanceRecord] = [], error: Error? = nil) {
        self.records = records
        self.error = error
    }
    
    func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord] {
        if let error { throw error }
        return records.filter { $0.exerciseName == exerciseName }
    }
    
    func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord] {
        if let error { throw error }
        lastQuery = query
        return records
    }
    
    func loadAllExerciseNames() throws -> [String] {
        if let error { throw error }
        return Array(Set(records.map(\.exerciseName))).sorted()
    }
}
