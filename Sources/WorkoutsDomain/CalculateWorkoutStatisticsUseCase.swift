import Foundation

public protocol WorkoutStatisticsCalculating {
    func calculate(for workout: Workout, duration: TimeInterval?) -> WorkoutStatistics
}

public final class CalculateWorkoutStatisticsUseCase: WorkoutStatisticsCalculating {
    public init() {}
    
    public func calculate(for workout: Workout, duration: TimeInterval? = nil) -> WorkoutStatistics {
        WorkoutStatistics.calculate(from: workout, duration: duration)
    }
}
