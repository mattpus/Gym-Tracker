import Foundation
import ProgressionDomain
import ProgressionData
import WorkoutsDomain

/// Factory for creating Progression-related use cases
@MainActor
final class ProgressionUseCaseFactory: Sendable {
    private let exerciseHistoryRepository: ExerciseHistoryRepository
    
    init(exerciseHistoryRepository: ExerciseHistoryRepository) {
        self.exerciseHistoryRepository = exerciseHistoryRepository
    }
    
    func makeProgressionRecommendationUseCase() -> ProgressionRecommendationProviding {
        let historyLoader = LocalExerciseHistoryForProgressionLoader(historyRepository: exerciseHistoryRepository)
        let progressionService = DummyProgressionService()
        return GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: progressionService
        )
    }
}
