import Foundation

public final class LoadExerciseHistoryUseCase: ExerciseHistoryLoading {
    private let repository: ExerciseHistoryRepository
    
    public init(repository: ExerciseHistoryRepository) {
        self.repository = repository
    }
    
    public func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord] {
        try repository.loadHistory(for: exerciseName)
    }
    
    public func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord] {
        try repository.loadHistory(query: query)
    }
}
