import Foundation

public protocol ExerciseHistoryRepository {
    func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord]
    func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord]
    func loadAllExerciseNames() throws -> [String]
}
