import Foundation
import ProgressionDomain

/// ViewModel for the Progression Dashboard
@Observable
@MainActor
final class ProgressionDashboardViewModel {
    var recommendations: [ProgressionRecommendationItem] = []
    var isLoading = false
    var error: Error?
    
    private let progressionRecommendationUseCase: ProgressionRecommendationProviding
    
    init(progressionRecommendationUseCase: ProgressionRecommendationProviding) {
        self.progressionRecommendationUseCase = progressionRecommendationUseCase
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        // Load recommendations for recent exercises
        // In a real implementation, we'd get the list of exercises the user has performed
        isLoading = false
    }
}

struct ProgressionRecommendationItem: Identifiable {
    let id = UUID()
    let exerciseName: String
    let currentWeight: Double
    let recommendedWeight: Double
    let currentReps: Int
    let recommendedReps: Int
    let reasoning: String
    
    init(recommendation: ProgressionRecommendation) {
        self.exerciseName = recommendation.exerciseName
        self.currentWeight = (recommendation.recommendedWeight ?? 0) - 2.5 // Approximate
        self.recommendedWeight = recommendation.recommendedWeight ?? 0
        self.currentReps = recommendation.recommendedReps ?? 0
        self.recommendedReps = recommendation.recommendedReps ?? 0
        self.reasoning = recommendation.reason
    }
    
    var weightChange: Double {
        recommendedWeight - currentWeight
    }
    
    var hasWeightIncrease: Bool {
        recommendedWeight > currentWeight
    }
}

/// ViewModel for individual exercise progression
@Observable
@MainActor
final class ExerciseProgressionViewModel {
    var recommendation: ProgressionRecommendationItem?
    var isLoading = false
    var error: Error?
    
    private let exerciseName: String
    private let progressionRecommendationUseCase: ProgressionRecommendationProviding
    
    init(
        exerciseName: String,
        progressionRecommendationUseCase: ProgressionRecommendationProviding
    ) {
        self.exerciseName = exerciseName
        self.progressionRecommendationUseCase = progressionRecommendationUseCase
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        do {
            let result = try progressionRecommendationUseCase.getRecommendation(for: exerciseName)
            recommendation = ProgressionRecommendationItem(recommendation: result)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
