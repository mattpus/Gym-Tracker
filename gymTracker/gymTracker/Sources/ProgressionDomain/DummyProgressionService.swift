import Foundation

/// A simple progression service that implements basic progressive overload rules.
/// This is a placeholder implementation - the actual algorithm will be developed later.
///
/// Current logic:
/// - If last set completed target reps (8+), recommend +2.5kg
/// - If last set was below target reps, recommend same weight, +1 rep target
/// - If no history, recommend starting weight based on exercise type
public final class DummyProgressionService: ProgressionService {
    
    private let defaultWeightIncrement: Double
    private let defaultRepIncrement: Int
    private let targetReps: Int
    
    public init(
        defaultWeightIncrement: Double = 2.5,
        defaultRepIncrement: Int = 1,
        targetReps: Int = 8
    ) {
        self.defaultWeightIncrement = defaultWeightIncrement
        self.defaultRepIncrement = defaultRepIncrement
        self.targetReps = targetReps
    }
    
    public func calculateRecommendation(
        for exerciseName: String,
        history: ExerciseHistoryForProgression,
        userProfile: UserProfile
    ) -> ProgressionRecommendation {
        
        // No history - provide starting recommendation
        guard let lastSet = history.lastSet else {
            return makeStartingRecommendation(for: exerciseName)
        }
        
        // No weight data - can't make weight recommendation
        guard let lastWeight = lastSet.weight else {
            return ProgressionRecommendation(
                exerciseName: exerciseName,
                recommendedWeight: nil,
                recommendedReps: (lastSet.reps ?? targetReps) + defaultRepIncrement,
                recommendationType: .increaseReps,
                reason: "Try to increase reps from your last session",
                confidence: .low
            )
        }
        
        let lastReps = lastSet.reps ?? 0
        
        // Check if user hit target reps - time to increase weight
        if lastReps >= targetReps {
            let newWeight = lastWeight + defaultWeightIncrement
            return ProgressionRecommendation(
                exerciseName: exerciseName,
                recommendedWeight: newWeight,
                recommendedReps: targetReps,
                recommendationType: .increaseWeight,
                reason: "Great job hitting \(lastReps) reps! Increase weight by \(formatWeight(defaultWeightIncrement))",
                confidence: .medium
            )
        }
        
        // User didn't hit target reps - keep weight, aim for more reps
        let targetRepCount = min(lastReps + defaultRepIncrement, targetReps)
        return ProgressionRecommendation(
            exerciseName: exerciseName,
            recommendedWeight: lastWeight,
            recommendedReps: targetRepCount,
            recommendationType: lastReps < targetReps - 2 ? .maintainCurrent : .increaseReps,
            reason: "Keep the weight at \(formatWeight(lastWeight)) and aim for \(targetRepCount) reps",
            confidence: .medium
        )
    }
    
    private func makeStartingRecommendation(for exerciseName: String) -> ProgressionRecommendation {
        // Simple starting weight suggestions based on common exercises
        let startingWeight = suggestStartingWeight(for: exerciseName)
        
        return ProgressionRecommendation(
            exerciseName: exerciseName,
            recommendedWeight: startingWeight,
            recommendedReps: targetReps,
            recommendationType: .noRecommendation,
            reason: "Start with \(formatWeight(startingWeight)) for \(targetReps) reps to establish baseline",
            confidence: .low
        )
    }
    
    private func suggestStartingWeight(for exerciseName: String) -> Double {
        let lowercaseName = exerciseName.lowercased()
        
        // Compound movements - higher starting weights
        if lowercaseName.contains("squat") || lowercaseName.contains("deadlift") {
            return 60.0
        }
        if lowercaseName.contains("bench") || lowercaseName.contains("row") {
            return 40.0
        }
        if lowercaseName.contains("press") {
            return 30.0
        }
        
        // Isolation movements - lower starting weights
        if lowercaseName.contains("curl") || lowercaseName.contains("extension") ||
           lowercaseName.contains("raise") || lowercaseName.contains("fly") {
            return 10.0
        }
        
        // Default
        return 20.0
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight == floor(weight) {
            return "\(Int(weight))kg"
        }
        return String(format: "%.1fkg", weight)
    }
}
