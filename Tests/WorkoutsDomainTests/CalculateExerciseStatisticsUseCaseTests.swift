import XCTest
@testable import WorkoutsDomain

final class CalculateExerciseStatisticsUseCaseTests: XCTestCase {
    
    func test_calculate_returnsStatisticsForExercise() throws {
        let records = makeRecords()
        let repository = MockExerciseHistoryRepository(records: records)
        let sut = CalculateExerciseStatisticsUseCase(historyRepository: repository)
        
        let stats = try sut.calculate(for: "Bench Press")
        
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.exerciseName, "Bench Press")
        XCTAssertEqual(stats?.totalSets, 2)
    }
    
    func test_calculate_returnsNilForUnknownExercise() throws {
        let repository = MockExerciseHistoryRepository(records: [])
        let sut = CalculateExerciseStatisticsUseCase(historyRepository: repository)
        
        let stats = try sut.calculate(for: "Unknown Exercise")
        
        XCTAssertNil(stats)
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
            ),
            ExercisePerformanceRecord(
                date: Date(),
                workoutId: UUID(),
                exerciseName: "Bench Press",
                setNumber: 2,
                weight: 100,
                repetitions: 8
            )
        ]
    }
}
