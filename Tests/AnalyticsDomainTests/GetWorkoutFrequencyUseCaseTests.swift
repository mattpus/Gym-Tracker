import XCTest
@testable import AnalyticsDomain

final class GetWorkoutFrequencyUseCaseTests: XCTestCase {
    
    func test_calculate_returnsCorrectTotalWorkouts() throws {
        let workouts = makeWorkouts(count: 5)
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetWorkoutFrequencyUseCase(repository: repository)
        
        let result = try sut.calculate()
        
        XCTAssertEqual(result.totalWorkouts, 5)
    }
    
    func test_calculate_returnsZeroForNoWorkouts() throws {
        let repository = MockWorkoutDataRepository(workouts: [])
        let sut = GetWorkoutFrequencyUseCase(repository: repository)
        
        let result = try sut.calculate()
        
        XCTAssertEqual(result.totalWorkouts, 0)
        XCTAssertEqual(result.currentStreak, 0)
        XCTAssertNil(result.lastWorkoutDate)
    }
    
    func test_calculate_returnsCorrectWorkoutsThisWeek() throws {
        let calendar = Calendar.current
        let today = Date()
        let workouts = [
            makeWorkout(date: today),
            makeWorkout(date: calendar.date(byAdding: .day, value: -1, to: today)!),
            makeWorkout(date: calendar.date(byAdding: .day, value: -10, to: today)!)
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetWorkoutFrequencyUseCase(repository: repository, calendar: calendar)
        
        let result = try sut.calculate()
        
        XCTAssertGreaterThanOrEqual(result.workoutsThisWeek, 1)
    }
    
    // MARK: - Helpers
    
    private func makeWorkouts(count: Int) -> [WorkoutData] {
        (0..<count).map { i in
            makeWorkout(date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!)
        }
    }
    
    private func makeWorkout(date: Date) -> WorkoutData {
        WorkoutData(
            id: UUID(),
            date: date,
            name: "Test Workout",
            totalVolume: 1000,
            exercises: []
        )
    }
}

final class MockWorkoutDataRepository: WorkoutDataRepository {
    private let workouts: [WorkoutData]
    
    init(workouts: [WorkoutData]) {
        self.workouts = workouts
    }
    
    func loadWorkouts(from startDate: Date?, to endDate: Date?) throws -> [WorkoutData] {
        var result = workouts
        if let start = startDate {
            result = result.filter { $0.date >= start }
        }
        if let end = endDate {
            result = result.filter { $0.date <= end }
        }
        return result
    }
}
