import XCTest
@testable import AnalyticsDomain

final class GetMuscleGroupDistributionUseCaseTests: XCTestCase {
    
    func test_calculate_returnsCorrectDistribution() throws {
        let workouts = [
            makeWorkout(exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: makeSets(count: 3)),
                ExerciseData(name: "Squat", muscleGroup: "quadriceps", sets: makeSets(count: 3))
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetMuscleGroupDistributionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.totalSets, 6)
        XCTAssertEqual(result.distribution.count, 2)
    }
    
    func test_calculate_identifiesMostAndLeastTrained() throws {
        let workouts = [
            makeWorkout(exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: makeSets(count: 5)),
                ExerciseData(name: "Curl", muscleGroup: "biceps", sets: makeSets(count: 2))
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetMuscleGroupDistributionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.mostTrainedMuscle, "chest")
        XCTAssertEqual(result.leastTrainedMuscle, "biceps")
    }
    
    func test_calculate_handlesNoExercises() throws {
        let repository = MockWorkoutDataRepository(workouts: [])
        let sut = GetMuscleGroupDistributionUseCase(repository: repository)
        
        let result = try sut.calculate(days: 30)
        
        XCTAssertEqual(result.totalSets, 0)
        XCTAssertTrue(result.distribution.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeWorkout(exercises: [ExerciseData]) -> WorkoutData {
        WorkoutData(
            id: UUID(),
            date: Date(),
            name: "Test Workout",
            totalVolume: 1000,
            exercises: exercises
        )
    }
    
    private func makeSets(count: Int) -> [SetData] {
        (0..<count).map { _ in SetData(weight: 100, reps: 10) }
    }
}
