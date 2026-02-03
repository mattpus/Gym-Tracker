import XCTest
@testable import ProgressionDomain

final class ExerciseHistoryForProgressionTests: XCTestCase {
    
    func test_lastSet_returnsFirstSetInArray() {
        let sets = [
            HistoricalSet(date: Date(), weight: 110, reps: 8),
            HistoricalSet(date: Date().addingTimeInterval(-86400), weight: 100, reps: 10)
        ]
        let history = ExerciseHistoryForProgression(exerciseName: "Bench Press", recentSets: sets, personalRecord: nil)
        
        XCTAssertEqual(history.lastSet?.weight, 110)
    }
    
    func test_averageWeight_calculatesCorrectly() {
        let sets = [
            HistoricalSet(date: Date(), weight: 100, reps: 10),
            HistoricalSet(date: Date(), weight: 110, reps: 8),
            HistoricalSet(date: Date(), weight: 120, reps: 6)
        ]
        let history = ExerciseHistoryForProgression(exerciseName: "Bench Press", recentSets: sets, personalRecord: nil)
        
        XCTAssertEqual(history.averageWeight, 110)
    }
    
    func test_averageReps_calculatesCorrectly() {
        let sets = [
            HistoricalSet(date: Date(), weight: 100, reps: 10),
            HistoricalSet(date: Date(), weight: 100, reps: 8),
            HistoricalSet(date: Date(), weight: 100, reps: 6)
        ]
        let history = ExerciseHistoryForProgression(exerciseName: "Bench Press", recentSets: sets, personalRecord: nil)
        
        XCTAssertEqual(history.averageReps, 8)
    }
    
    func test_historicalSet_calculatesVolume() {
        let set = HistoricalSet(date: Date(), weight: 100, reps: 10)
        
        XCTAssertEqual(set.volume, 1000)
    }
    
    func test_historicalSet_volumeIsNilWithoutWeight() {
        let set = HistoricalSet(date: Date(), weight: nil, reps: 10)
        
        XCTAssertNil(set.volume)
    }
}
