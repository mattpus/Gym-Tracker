import Foundation
import Observation

/// ViewModel for the Progression Dashboard
@Observable
@MainActor
final class ProgressionDashboardViewModel {
    var recommendations: [ProgressionRecommendationItem] = []
    var isLoading = false
    var error: Error?
    
    private let progressionRecommendationUseCase: ProgressionRecommendationProviding
    private let loadExerciseNames: () throws -> [String]
    
    init(
        progressionRecommendationUseCase: ProgressionRecommendationProviding,
        loadExerciseNames: @escaping () throws -> [String]
    ) {
        self.progressionRecommendationUseCase = progressionRecommendationUseCase
        self.loadExerciseNames = loadExerciseNames
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        do {
            let exerciseNames = try loadExerciseNames()
            let uniqueExerciseNames = Array(Set(exerciseNames)).sorted()
            
            recommendations = uniqueExerciseNames.prefix(6).compactMap { exerciseName in
                do {
                    let recommendation = try progressionRecommendationUseCase.getRecommendation(for: exerciseName)
                    return ProgressionRecommendationItem(recommendation: recommendation)
                } catch {
                    return nil
                }
            }
        } catch {
            self.error = error
            recommendations = []
        }
        
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
    let confidence: ConfidenceLevel
    let recommendationType: RecommendationType
    
    init(recommendation: ProgressionRecommendation) {
        self.exerciseName = recommendation.exerciseName
        self.currentWeight = max((recommendation.recommendedWeight ?? 0) - 2.5, 0)
        self.recommendedWeight = recommendation.recommendedWeight ?? 0
        self.currentReps = max((recommendation.recommendedReps ?? 0) - 1, 0)
        self.recommendedReps = recommendation.recommendedReps ?? 0
        self.reasoning = recommendation.reason
        self.confidence = recommendation.confidence
        self.recommendationType = recommendation.recommendationType
    }
    
    var weightChange: Double {
        recommendedWeight - currentWeight
    }
    
    var hasWeightIncrease: Bool {
        recommendationType == .increaseWeight && recommendedWeight > currentWeight
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
