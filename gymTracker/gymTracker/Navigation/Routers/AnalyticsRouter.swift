import Foundation
import Observation

@Observable
@MainActor
final class AnalyticsRouter {
    let navigation: NavigationRouter
    private let container: DependencyContainer
    private(set) var dashboardViewModel: AnalyticsDashboardViewModel

    init(container: DependencyContainer, navigation: NavigationRouter) {
        self.container = container
        self.navigation = navigation
        self.dashboardViewModel = AnalyticsDashboardViewModel(
            workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase(),
            muscleDistributionUseCase: container.analyticsUseCaseFactory.makeMuscleGroupDistributionUseCase(),
            weeklyInsightsUseCase: container.analyticsUseCaseFactory.makeWeeklyInsightsUseCase()
        )
    }

    func showWorkoutFrequency() { navigation.push(.workoutFrequency) }
    func showMuscleDistribution() { navigation.push(.muscleDistribution) }
    func showWeightProgression(exerciseName: String) { navigation.push(.weightProgression(exerciseName: exerciseName)) }
    func showVolumeProgression() { navigation.push(.volumeProgression) }
    func showRecovery() { navigation.push(.recovery) }

    func makeWorkoutFrequencyViewModel() -> WorkoutFrequencyViewModel {
        WorkoutFrequencyViewModel(workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase())
    }

    func makeMuscleDistributionViewModel() -> MuscleDistributionViewModel {
        MuscleDistributionViewModel(muscleDistributionUseCase: container.analyticsUseCaseFactory.makeMuscleGroupDistributionUseCase())
    }

    func makeWeightProgressionViewModel(exerciseName: String) -> WeightProgressionViewModel {
        WeightProgressionViewModel(
            exerciseName: exerciseName,
            weightProgressionUseCase: container.analyticsUseCaseFactory.makeWeightProgressionUseCase()
        )
    }

    func makeVolumeProgressionViewModel() -> VolumeProgressionViewModel {
        VolumeProgressionViewModel(volumeProgressionUseCase: container.analyticsUseCaseFactory.makeVolumeProgressionUseCase())
    }

    func makeRecoveryViewModel() -> RecoveryViewModel {
        RecoveryViewModel(recoveryStatusUseCase: container.analyticsUseCaseFactory.makeRecoveryStatusUseCase())
    }
}
