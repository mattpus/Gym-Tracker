import Foundation

public protocol WorkoutFrequencyPresenterOutput: AnyObject {
    func display(_ viewModel: AnalyticsWorkoutFrequencyViewModel)
}

public final class WorkoutFrequencyPresenter {
    public weak var output: WorkoutFrequencyPresenterOutput?
    
    public init() {}
    
    public func present(_ insight: WorkoutFrequencyInsight) {
        let lastWorkoutText: String
        if let days = insight.daysSinceLastWorkout {
            switch days {
            case 0: lastWorkoutText = "Today"
            case 1: lastWorkoutText = "Yesterday"
            default: lastWorkoutText = "\(days) days ago"
            }
        } else {
            lastWorkoutText = "No workouts yet"
        }
        
        let viewModel = AnalyticsWorkoutFrequencyViewModel(
            totalWorkouts: "\(insight.totalWorkouts)",
            workoutsThisWeek: "\(insight.workoutsThisWeek)",
            workoutsThisMonth: "\(insight.workoutsThisMonth)",
            averagePerWeek: String(format: "%.1f", insight.averageWorkoutsPerWeek),
            currentStreak: "\(insight.currentStreak) days",
            longestStreak: "\(insight.longestStreak) days",
            lastWorkoutText: lastWorkoutText
        )
        
        output?.display(viewModel)
    }
}
