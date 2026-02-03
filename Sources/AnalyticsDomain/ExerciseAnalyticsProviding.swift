import Foundation

public protocol ExerciseAnalyticsProviding {
    func getWeightProgression(for exerciseName: String, days: Int) throws -> WeightProgressionTrend
}
