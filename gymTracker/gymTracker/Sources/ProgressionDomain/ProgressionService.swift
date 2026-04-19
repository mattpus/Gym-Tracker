import Foundation

public protocol ProgressionService {
    func calculateRecommendation(
        for exerciseName: String,
        history: ExerciseHistoryForProgression,
        userProfile: UserProfile
    ) -> ProgressionRecommendation
}
