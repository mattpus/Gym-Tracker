import Foundation

public protocol ExerciseStatisticsCalculating {
    func calculate(for exerciseName: String) throws -> ExerciseStatistics?
}

public final class CalculateExerciseStatisticsUseCase: ExerciseStatisticsCalculating {
    private let historyRepository: ExerciseHistoryRepository
    
    public init(historyRepository: ExerciseHistoryRepository) {
        self.historyRepository = historyRepository
    }
    
    public func calculate(for exerciseName: String) throws -> ExerciseStatistics? {
        let records = try historyRepository.loadHistory(for: exerciseName)
        return ExerciseStatistics.calculate(from: records)
    }
}
