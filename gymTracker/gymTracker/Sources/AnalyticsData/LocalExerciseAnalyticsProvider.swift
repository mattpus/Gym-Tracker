import Foundation

public final class LocalExerciseAnalyticsProvider: ExerciseAnalyticsProviding {
    private let weightProgressionUseCase: WeightProgressionCalculating
    
    public init(weightProgressionUseCase: WeightProgressionCalculating) {
        self.weightProgressionUseCase = weightProgressionUseCase
    }
    
    public func getWeightProgression(for exerciseName: String, days: Int) throws -> WeightProgressionTrend {
        try weightProgressionUseCase.calculate(for: exerciseName, days: days)
    }
}
