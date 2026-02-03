import XCTest
@testable import WorkoutsDomain

final class ExerciseStatisticsTests: XCTestCase {
    
    func test_calculate_returnsNilForEmptyRecords() {
        let stats = ExerciseStatistics.calculate(from: [])
        
        XCTAssertNil(stats)
    }
    
    func test_calculate_computesCorrectStatistics() {
        let records = [
            makeRecord(date: date(daysAgo: 7), weight: 100, reps: 10),
            makeRecord(date: date(daysAgo: 7), weight: 100, reps: 8),
            makeRecord(date: date(daysAgo: 3), weight: 105, reps: 10),
            makeRecord(date: date(daysAgo: 3), weight: 105, reps: 8),
            makeRecord(date: date(daysAgo: 0), weight: 110, reps: 10)
        ]
        
        let stats = ExerciseStatistics.calculate(from: records)!
        
        XCTAssertEqual(stats.exerciseName, "Bench Press")
        XCTAssertEqual(stats.totalSessions, 3)
        XCTAssertEqual(stats.totalSets, 5)
        XCTAssertEqual(stats.totalReps, 46)
        XCTAssertEqual(stats.maxWeight, 110)
        XCTAssertEqual(stats.maxReps, 10)
    }
    
    func test_calculate_computesTotalVolume() {
        let records = [
            makeRecord(weight: 100, reps: 10), // 1000
            makeRecord(weight: 100, reps: 8),  // 800
            makeRecord(weight: 105, reps: 6)   // 630
        ]
        
        let stats = ExerciseStatistics.calculate(from: records)!
        
        XCTAssertEqual(stats.totalVolume, 2430)
    }
    
    func test_calculate_computesAverages() {
        let records = [
            makeRecord(weight: 100, reps: 10),
            makeRecord(weight: 110, reps: 8),
            makeRecord(weight: 120, reps: 6)
        ]
        
        let stats = ExerciseStatistics.calculate(from: records)!
        
        XCTAssertEqual(stats.averageWeight, 110) // (100+110+120)/3
        XCTAssertEqual(stats.averageReps, 8)     // (10+8+6)/3
    }
    
    func test_calculate_tracksFirstAndLastPerformed() {
        let oldDate = date(daysAgo: 30)
        let recentDate = date(daysAgo: 1)
        
        let records = [
            makeRecord(date: date(daysAgo: 15), weight: 100, reps: 10),
            makeRecord(date: oldDate, weight: 100, reps: 10),
            makeRecord(date: recentDate, weight: 100, reps: 10)
        ]
        
        let stats = ExerciseStatistics.calculate(from: records)!
        
        XCTAssertEqual(stats.firstPerformed, oldDate)
        XCTAssertEqual(stats.lastPerformed, recentDate)
    }
    
    // MARK: - Helpers
    
    private func makeRecord(
        date: Date = Date(),
        exerciseName: String = "Bench Press",
        weight: Double?,
        reps: Int?
    ) -> ExercisePerformanceRecord {
        ExercisePerformanceRecord(
            date: date,
            workoutId: UUID(),
            exerciseName: exerciseName,
            setNumber: 1,
            weight: weight,
            repetitions: reps
        )
    }
    
    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }
}
