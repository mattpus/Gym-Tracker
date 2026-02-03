import Foundation
import AnalyticsDomain

public final class LocalWorkoutAnalyticsProvider: WorkoutAnalyticsProviding {
    private let frequencyUseCase: WorkoutFrequencyCalculating
    private let volumeUseCase: VolumeProgressionCalculating
    private let weeklyUseCase: WeeklyInsightsGenerating
    
    public init(
        frequencyUseCase: WorkoutFrequencyCalculating,
        volumeUseCase: VolumeProgressionCalculating,
        weeklyUseCase: WeeklyInsightsGenerating
    ) {
        self.frequencyUseCase = frequencyUseCase
        self.volumeUseCase = volumeUseCase
        self.weeklyUseCase = weeklyUseCase
    }
    
    public func getWorkoutFrequency() throws -> WorkoutFrequencyInsight {
        try frequencyUseCase.calculate()
    }
    
    public func getVolumeProgression(days: Int) throws -> VolumeProgressionTrend {
        try volumeUseCase.calculate(days: days)
    }
    
    public func getWeeklyInsights() throws -> WeeklyInsightsSummary {
        try weeklyUseCase.generate()
    }
}
