import Foundation

public protocol WorkoutAnalyticsProviding {
    func getWorkoutFrequency() throws -> WorkoutFrequencyInsight
    func getVolumeProgression(days: Int) throws -> VolumeProgressionTrend
    func getWeeklyInsights() throws -> WeeklyInsightsSummary
}
