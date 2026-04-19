import Foundation

public protocol ProgressionRecommendationProviding {
    func getRecommendation(for exerciseName: String) throws -> ProgressionRecommendation
}

public protocol ExerciseHistoryForProgressionLoading {
    func loadHistory(for exerciseName: String, limit: Int) throws -> ExerciseHistoryForProgression
}

public final class GetProgressionRecommendationUseCase: ProgressionRecommendationProviding {
    private let historyLoader: ExerciseHistoryForProgressionLoading
    private let progressionService: ProgressionService
    private let userProfile: UserProfile
    
    public init(
        historyLoader: ExerciseHistoryForProgressionLoading,
        progressionService: ProgressionService,
        userProfile: UserProfile = .default
    ) {
        self.historyLoader = historyLoader
        self.progressionService = progressionService
        self.userProfile = userProfile
    }
    
    public func getRecommendation(for exerciseName: String) throws -> ProgressionRecommendation {
        let history = try historyLoader.loadHistory(for: exerciseName, limit: 10)
        return progressionService.calculateRecommendation(
            for: exerciseName,
            history: history,
            userProfile: userProfile
        )
    }
}
