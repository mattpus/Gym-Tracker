import XCTest
@testable import ProgressionDomain

final class DummyProgressionServiceTests: XCTestCase {
    
    func test_calculateRecommendation_suggestsWeightIncreaseWhenTargetRepsHit() {
        let sut = DummyProgressionService(defaultWeightIncrement: 2.5, targetReps: 8)
        let history = makeHistory(lastWeight: 100, lastReps: 10)
        
        let result = sut.calculateRecommendation(for: "Bench Press", history: history, userProfile: .default)
        
        XCTAssertEqual(result.recommendationType, .increaseWeight)
        XCTAssertEqual(result.recommendedWeight, 102.5)
    }
    
    func test_calculateRecommendation_suggestsMaintainWhenBelowTargetReps() {
        let sut = DummyProgressionService(defaultWeightIncrement: 2.5, targetReps: 8)
        let history = makeHistory(lastWeight: 100, lastReps: 5)
        
        let result = sut.calculateRecommendation(for: "Bench Press", history: history, userProfile: .default)
        
        XCTAssertEqual(result.recommendationType, .maintainCurrent)
        XCTAssertEqual(result.recommendedWeight, 100)
        XCTAssertEqual(result.recommendedReps, 6)
    }
    
    func test_calculateRecommendation_suggestsIncreaseRepsWhenCloseToTarget() {
        let sut = DummyProgressionService(defaultWeightIncrement: 2.5, targetReps: 8)
        let history = makeHistory(lastWeight: 100, lastReps: 7)
        
        let result = sut.calculateRecommendation(for: "Bench Press", history: history, userProfile: .default)
        
        XCTAssertEqual(result.recommendationType, .increaseReps)
        XCTAssertEqual(result.recommendedReps, 8)
    }
    
    func test_calculateRecommendation_suggestsStartingWeightForNoHistory() {
        let sut = DummyProgressionService()
        let history = ExerciseHistoryForProgression(exerciseName: "Bench Press", recentSets: [], personalRecord: nil)
        
        let result = sut.calculateRecommendation(for: "Bench Press", history: history, userProfile: .default)
        
        XCTAssertEqual(result.recommendationType, .noRecommendation)
        XCTAssertNotNil(result.recommendedWeight)
        XCTAssertEqual(result.confidence, .low)
    }
    
    func test_calculateRecommendation_suggestsHigherStartingWeightForCompoundMovements() {
        let sut = DummyProgressionService()
        let emptyHistory = ExerciseHistoryForProgression(exerciseName: "", recentSets: [], personalRecord: nil)
        
        let squatResult = sut.calculateRecommendation(for: "Squat", history: emptyHistory, userProfile: .default)
        let curlResult = sut.calculateRecommendation(for: "Bicep Curl", history: emptyHistory, userProfile: .default)
        
        XCTAssertGreaterThan(squatResult.recommendedWeight ?? 0, curlResult.recommendedWeight ?? 0)
    }
    
    // MARK: - Helpers
    
    private func makeHistory(lastWeight: Double, lastReps: Int) -> ExerciseHistoryForProgression {
        let set = HistoricalSet(date: Date(), weight: lastWeight, reps: lastReps)
        return ExerciseHistoryForProgression(
            exerciseName: "Bench Press",
            recentSets: [set],
            personalRecord: nil
        )
    }
}
