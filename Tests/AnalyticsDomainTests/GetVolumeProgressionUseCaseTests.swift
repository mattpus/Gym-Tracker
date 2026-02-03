import XCTest
@testable import AnalyticsDomain

final class GetVolumeProgressionUseCaseTests: XCTestCase {
    
    func test_calculate_returnsCorrectTotalVolume() throws {
        let workouts = [
            makeWorkout(volume: 1000),
            makeWorkout(volume: 1500),
            makeWorkout(volume: 2000)
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetVolumeProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.totalVolume, 4500)
    }
    
    func test_calculate_returnsCorrectAverageVolume() throws {
        let workouts = [
            makeWorkout(volume: 1000),
            makeWorkout(volume: 2000)
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetVolumeProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.averageVolumePerWorkout, 1500)
    }
    
    func test_calculate_detectsIncreasingTrend() throws {
        let calendar = Calendar.current
        let today = Date()
        let workouts = [
            makeWorkout(date: calendar.date(byAdding: .day, value: -10, to: today)!, volume: 1000),
            makeWorkout(date: calendar.date(byAdding: .day, value: -5, to: today)!, volume: 1500),
            makeWorkout(date: today, volume: 2000)
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetVolumeProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.trend, .increasing)
    }
    
    func test_calculate_returnsInsufficientForSingleWorkout() throws {
        let workouts = [makeWorkout(volume: 1000)]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetVolumeProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.trend, .insufficient)
    }
    
    // MARK: - Helpers
    
    private func makeWorkout(date: Date = Date(), volume: Double) -> WorkoutData {
        WorkoutData(
            id: UUID(),
            date: date,
            name: "Test Workout",
            totalVolume: volume,
            exercises: []
        )
    }
}
