import Foundation
import WorkoutsDomain
import AnalyticsDomain

/// ViewModel for the Home tab
@Observable
@MainActor
final class HomeViewModel {
    var recentWorkouts: [WorkoutItemViewModel] = []
    var currentStreak: Int = 0
    var workoutsThisWeek: Int = 0
    var isLoading = false
    
    private let loadWorkoutsUseCase: WorkoutsLoading
    private let workoutFrequencyUseCase: WorkoutFrequencyCalculating
    
    init(
        loadWorkoutsUseCase: WorkoutsLoading,
        workoutFrequencyUseCase: WorkoutFrequencyCalculating
    ) {
        self.loadWorkoutsUseCase = loadWorkoutsUseCase
        self.workoutFrequencyUseCase = workoutFrequencyUseCase
    }
    
    func loadData() {
        isLoading = true
        
        loadWorkoutsUseCase.load { [weak self] result in
            Task { @MainActor in
                if case .success(let workouts) = result {
                    self?.recentWorkouts = workouts
                        .sorted { $0.date > $1.date }
                        .prefix(3)
                        .map { WorkoutItemViewModel(workout: $0) }
                }
            }
        }
        
        do {
            let insight = try workoutFrequencyUseCase.calculate()
            currentStreak = insight.currentStreak
            workoutsThisWeek = insight.workoutsThisWeek
        } catch {
            // Handle error
        }
        
        isLoading = false
    }
}
