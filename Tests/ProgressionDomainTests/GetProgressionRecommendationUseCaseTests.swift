import XCTest
@testable import ProgressionDomain

final class GetProgressionRecommendationUseCaseTests: XCTestCase {
    
    func test_getRecommendation_returnsRecommendationFromService() throws {
        let history = ExerciseHistoryForProgression(
            exerciseName: "Bench Press",
            recentSets: [HistoricalSet(date: Date(), weight: 100, reps: 10)],
            personalRecord: nil
        )
        let historyLoader = MockHistoryLoader(history: history)
        let service = DummyProgressionService()
        let sut = GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: service
        )
        
        let result = try sut.getRecommendation(for: "Bench Press")
        
        XCTAssertEqual(result.exerciseName, "Bench Press")
        XCTAssertNotNil(result.recommendedWeight)
    }
    
    func test_getRecommendation_passesExerciseNameToHistoryLoader() throws {
        let historyLoader = MockHistoryLoader()
        let service = DummyProgressionService()
        let sut = GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: service
        )
        
        _ = try sut.getRecommendation(for: "Squat")
        
        XCTAssertEqual(historyLoader.lastExerciseName, "Squat")
    }
    
    func test_getRecommendation_throwsErrorWhenHistoryLoaderFails() {
        let historyLoader = MockHistoryLoader(error: NSError(domain: "test", code: 1))
        let service = DummyProgressionService()
        let sut = GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: service
        )
        
        XCTAssertThrowsError(try sut.getRecommendation(for: "Bench Press"))
    }
}

final class MockHistoryLoader: ExerciseHistoryForProgressionLoading {
    private let history: ExerciseHistoryForProgression
    private let error: Error?
    private(set) var lastExerciseName: String?
    
    init(
        history: ExerciseHistoryForProgression = ExerciseHistoryForProgression(exerciseName: "", recentSets: [], personalRecord: nil),
        error: Error? = nil
    ) {
        self.history = history
        self.error = error
    }
    
    func loadHistory(for exerciseName: String, limit: Int) throws -> ExerciseHistoryForProgression {
        lastExerciseName = exerciseName
        if let error { throw error }
        return ExerciseHistoryForProgression(
            exerciseName: exerciseName,
            recentSets: history.recentSets,
            personalRecord: history.personalRecord
        )
    }
}
