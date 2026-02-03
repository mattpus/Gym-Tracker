import XCTest
@testable import WorkoutsDomain

final class WorkoutStatisticsTests: XCTestCase {
    
    func test_calculate_returnsCorrectStatisticsForWorkout() {
        let workout = makeWorkout(exercises: [
            makeExercise(name: "Bench Press", sets: [
                makeSet(order: 1, weight: 100, reps: 10),
                makeSet(order: 2, weight: 100, reps: 8),
                makeSet(order: 3, weight: 100, reps: 6)
            ]),
            makeExercise(name: "Squat", sets: [
                makeSet(order: 1, weight: 120, reps: 8),
                makeSet(order: 2, weight: 120, reps: 8)
            ])
        ])
        
        let stats = WorkoutStatistics.calculate(from: workout, duration: 3600)
        
        XCTAssertEqual(stats.exerciseCount, 2)
        XCTAssertEqual(stats.setCount, 5)
        XCTAssertEqual(stats.totalReps, 40) // 10+8+6+8+8
        XCTAssertEqual(stats.totalVolume, 4320) // (100*10 + 100*8 + 100*6) + (120*8 + 120*8)
        XCTAssertEqual(stats.duration, 3600)
    }
    
    func test_calculate_handlesEmptyWorkout() {
        let workout = makeWorkout(exercises: [])
        
        let stats = WorkoutStatistics.calculate(from: workout)
        
        XCTAssertEqual(stats.exerciseCount, 0)
        XCTAssertEqual(stats.setCount, 0)
        XCTAssertEqual(stats.totalReps, 0)
        XCTAssertEqual(stats.totalVolume, 0)
    }
    
    func test_calculate_handlesBodyweightExercises() {
        let workout = makeWorkout(exercises: [
            makeExercise(name: "Push-ups", sets: [
                makeSet(order: 1, weight: nil, reps: 20),
                makeSet(order: 2, weight: nil, reps: 15)
            ])
        ])
        
        let stats = WorkoutStatistics.calculate(from: workout)
        
        XCTAssertEqual(stats.setCount, 2)
        XCTAssertEqual(stats.totalReps, 35)
        XCTAssertEqual(stats.totalVolume, 0) // No weight = no volume
    }
    
    // MARK: - Helpers
    
    private func makeWorkout(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String = "Test Workout",
        exercises: [Exercise]
    ) -> Workout {
        Workout(id: id, date: date, name: name, exercises: exercises)
    }
    
    private func makeExercise(name: String, sets: [ExerciseSet]) -> Exercise {
        Exercise(id: UUID(), name: name, sets: sets)
    }
    
    private func makeSet(order: Int, weight: Double?, reps: Int?) -> ExerciseSet {
        ExerciseSet(id: UUID(), order: order, repetitions: reps, weight: weight)
    }
}
