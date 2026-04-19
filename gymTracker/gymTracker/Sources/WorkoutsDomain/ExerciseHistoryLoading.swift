import Foundation

public protocol ExerciseHistoryLoading {
    func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord]
    func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord]
}
