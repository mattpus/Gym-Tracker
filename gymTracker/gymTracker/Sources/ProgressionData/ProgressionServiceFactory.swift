import Foundation

/// Factory for creating progression-related use cases with proper dependencies
public final class ProgressionServiceFactory {
    private let historyLoader: ExerciseHistoryForProgressionLoading
    
    public init(historyLoader: ExerciseHistoryForProgressionLoading) {
        self.historyLoader = historyLoader
    }
    
    public func makeProgressionRecommendationUseCase(
        userProfile: UserProfile = .default
    ) -> GetProgressionRecommendationUseCase {
        let service = DummyProgressionService()
        return GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: service,
            userProfile: userProfile
        )
    }
    
    public func makeProgressionRecommendationUseCase(
        service: ProgressionService,
        userProfile: UserProfile = .default
    ) -> GetProgressionRecommendationUseCase {
        GetProgressionRecommendationUseCase(
            historyLoader: historyLoader,
            progressionService: service,
            userProfile: userProfile
        )
    }
}
