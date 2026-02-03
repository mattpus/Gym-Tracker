import SwiftUI
import AnalyticsDomain

/// Coordinator for the Analytics tab - handles analytics dashboard and detail views
@Observable
@MainActor
final class AnalyticsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    private let container: DependencyContainer
    private(set) var analyticsDashboardViewModel: AnalyticsDashboardViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        analyticsDashboardViewModel = makeAnalyticsDashboardViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        AnalyticsCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func destinationView(for destination: AnalyticsDestination) -> some View {
        switch destination {
        case .workoutFrequency:
            WorkoutFrequencyView(viewModel: makeWorkoutFrequencyViewModel())
        case .muscleDistribution:
            MuscleDistributionView(viewModel: makeMuscleDistributionViewModel())
        case .weightProgression(let exerciseName):
            WeightProgressionView(viewModel: makeWeightProgressionViewModel(exerciseName: exerciseName))
        case .volumeProgression:
            VolumeProgressionView(viewModel: makeVolumeProgressionViewModel())
        case .recovery:
            RecoveryView(viewModel: makeRecoveryViewModel())
        }
    }
    
    // MARK: - Navigation Actions
    
    func showWorkoutFrequency() {
        navigationPath.append(AnalyticsDestination.workoutFrequency)
    }
    
    func showMuscleDistribution() {
        navigationPath.append(AnalyticsDestination.muscleDistribution)
    }
    
    func showWeightProgression(exerciseName: String) {
        navigationPath.append(AnalyticsDestination.weightProgression(exerciseName: exerciseName))
    }
    
    func showVolumeProgression() {
        navigationPath.append(AnalyticsDestination.volumeProgression)
    }
    
    func showRecovery() {
        navigationPath.append(AnalyticsDestination.recovery)
    }
    
    // MARK: - ViewModel Factories
    
    private func makeAnalyticsDashboardViewModel() -> AnalyticsDashboardViewModel {
        AnalyticsDashboardViewModel(
            workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase(),
            muscleDistributionUseCase: container.analyticsUseCaseFactory.makeMuscleGroupDistributionUseCase(),
            weeklyInsightsUseCase: container.analyticsUseCaseFactory.makeWeeklyInsightsUseCase()
        )
    }
    
    private func makeWorkoutFrequencyViewModel() -> WorkoutFrequencyViewModel {
        WorkoutFrequencyViewModel(
            workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase()
        )
    }
    
    private func makeMuscleDistributionViewModel() -> MuscleDistributionViewModel {
        MuscleDistributionViewModel(
            muscleDistributionUseCase: container.analyticsUseCaseFactory.makeMuscleGroupDistributionUseCase()
        )
    }
    
    private func makeWeightProgressionViewModel(exerciseName: String) -> WeightProgressionViewModel {
        WeightProgressionViewModel(
            exerciseName: exerciseName,
            weightProgressionUseCase: container.analyticsUseCaseFactory.makeWeightProgressionUseCase()
        )
    }
    
    private func makeVolumeProgressionViewModel() -> VolumeProgressionViewModel {
        VolumeProgressionViewModel(
            volumeProgressionUseCase: container.analyticsUseCaseFactory.makeVolumeProgressionUseCase()
        )
    }
    
    private func makeRecoveryViewModel() -> RecoveryViewModel {
        RecoveryViewModel(
            recoveryStatusUseCase: container.analyticsUseCaseFactory.makeRecoveryStatusUseCase()
        )
    }
}

/// Navigation destinations for the Analytics flow
enum AnalyticsDestination: Hashable {
    case workoutFrequency
    case muscleDistribution
    case weightProgression(exerciseName: String)
    case volumeProgression
    case recovery
}

/// Internal content view that uses @Bindable for navigation
private struct AnalyticsCoordinatorContentView: View {
    @Bindable var coordinator: AnalyticsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.analyticsDashboardViewModel {
                AnalyticsDashboardView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: AnalyticsDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
    }
}

/// View wrapper for AnalyticsCoordinator
struct AnalyticsCoordinatorView: View {
    let coordinator: AnalyticsCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
