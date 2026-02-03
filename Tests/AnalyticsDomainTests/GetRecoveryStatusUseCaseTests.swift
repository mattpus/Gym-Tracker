import XCTest
@testable import AnalyticsDomain

final class GetRecoveryStatusUseCaseTests: XCTestCase {
    
    func test_calculate_returnsRecoveryStatusForAllMuscleGroups() throws {
        let repository = MockWorkoutDataRepository(workouts: [])
        let muscleGroups = ["chest", "back", "shoulders"]
        let sut = GetRecoveryStatusUseCase(repository: repository, muscleGroups: muscleGroups)
        
        let result = try sut.calculate()
        
        XCTAssertEqual(result.muscleGroupRecovery.count, 3)
    }
    
    func test_calculate_marksRecentlyTrainedMuscle() throws {
        let workouts = [
            makeWorkout(date: Date(), exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: [SetData(weight: 100, reps: 10)])
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetRecoveryStatusUseCase(repository: repository, muscleGroups: ["chest", "back"])
        
        let result = try sut.calculate()
        
        let chestStatus = result.muscleGroupRecovery.first { $0.muscleGroup == "chest" }
        XCTAssertEqual(chestStatus?.recoveryStatus, .recentlyTrained)
    }
    
    func test_calculate_marksUntrainedMuscleAsNeverTrained() throws {
        let repository = MockWorkoutDataRepository(workouts: [])
        let sut = GetRecoveryStatusUseCase(repository: repository, muscleGroups: ["chest"])
        
        let result = try sut.calculate()
        
        let chestStatus = result.muscleGroupRecovery.first { $0.muscleGroup == "chest" }
        XCTAssertEqual(chestStatus?.recoveryStatus, .neverTrained)
    }
    
    func test_calculate_categorizesRecoveredMuscles() throws {
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        let workouts = [
            makeWorkout(date: threeDaysAgo, exercises: [
                ExerciseData(name: "Bench Press", muscleGroup: "chest", sets: [SetData(weight: 100, reps: 10)])
            ])
        ]
        let repository = MockWorkoutDataRepository(workouts: workouts)
        let sut = GetRecoveryStatusUseCase(repository: repository, muscleGroups: ["chest"])
        
        let result = try sut.calculate()
        
        XCTAssertTrue(result.fullyRecoveredMuscles.contains("chest"))
    }
    
    // MARK: - Helpers
    
    private func makeWorkout(date: Date, exercises: [ExerciseData]) -> WorkoutData {
        WorkoutData(
            id: UUID(),
            date: date,
            name: "Test Workout",
            totalVolume: 1000,
            exercises: exercises
        )
    }
}
