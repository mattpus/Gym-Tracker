import XCTest
@testable import AnalyticsDomain

final class GetWeightProgressionUseCaseTests: XCTestCase {
    
    func test_calculate_returnsDataPointsForExercise() throws {
        let calendar = Calendar.current
        let today = Date()
        let workouts = [
            makeWorkout(date: calendar.date(byAdding: .day, value: -7, to: today)!, exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: [
                    SetData(weight: 100, reps: 10)
                ])
            ]),
            makeWorkout(date: today, exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: [
                    SetData(weight: 110, reps: 10)
                ])
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetWeightProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(for: "Bench Press", days: 30)
        
        XCTAssertEqual(result.exerciseName, "Bench Press")
        XCTAssertEqual(result.dataPoints.count, 2)
        XCTAssertEqual(result.startingWeight, 100)
        XCTAssertEqual(result.currentWeight, 110)
    }
    
    func test_calculate_detectsIncreasingTrend() throws {
        let calendar = Calendar.current
        let today = Date()
        let workouts = [
            makeWorkout(date: calendar.date(byAdding: .day, value: -7, to: today)!, exercises: [
                ExerciseData(name: "Squat", muscleGroup: "quadriceps", sets: [SetData(weight: 100, reps: 10)])
            ]),
            makeWorkout(date: today, exercises: [
                ExerciseData(name: "Squat", muscleGroup: "quadriceps", sets: [SetData(weight: 120, reps: 10)])
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetWeightProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(for: "Squat", days: 30)
        
        XCTAssertEqual(result.trend, .increasing)
        XCTAssertEqual(result.maxWeight, 120)
    }
    
    func test_calculate_returnsEmptyForUnknownExercise() throws {
        let workouts = [
            makeWorkout(exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: [SetData(weight: 100, reps: 10)])
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetWeightProgressionUseCase(repository: repository)
        
        let result = try sut.calculate(for: "Unknown Exercise", days: 30)
        
        XCTAssertTrue(result.dataPoints.isEmpty)
        XCTAssertEqual(result.trend, .insufficient)
    }
    
    // MARK: - Helpers
    
    private func makeWorkout(date: Date = Date(), exercises: [ExerciseData]) -> WorkoutData {
        WorkoutData(
            id: UUID(),
            date: date,
            name: "Test Workout",
            totalVolume: 1000,
            exercises: exercises
        )
    }
}
