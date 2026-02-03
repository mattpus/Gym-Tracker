import Foundation

public struct ProgressionRecommendation: Equatable, Sendable {
    public let exerciseName: String
    public let recommendedWeight: Double?
    public let recommendedReps: Int?
    public let recommendationType: RecommendationType
    public let reason: String
    public let confidence: ConfidenceLevel
    
    public init(
        exerciseName: String,
        recommendedWeight: Double?,
        recommendedReps: Int?,
        recommendationType: RecommendationType,
        reason: String,
        confidence: ConfidenceLevel
    ) {
        self.exerciseName = exerciseName
        self.recommendedWeight = recommendedWeight
        self.recommendedReps = recommendedReps
        self.recommendationType = recommendationType
        self.reason = reason
        self.confidence = confidence
    }
}

public enum RecommendationType: String, Equatable, Sendable {
    case increaseWeight
    case increaseReps
    case maintainCurrent
    case deload
    case noRecommendation
}

public enum ConfidenceLevel: String, Equatable, Sendable {
    case high
    case medium
    case low
    case insufficient
}
