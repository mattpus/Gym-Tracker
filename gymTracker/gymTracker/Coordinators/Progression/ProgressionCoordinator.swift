import SwiftUI
import Observation

/// Coordinator for the Progression tab - handles progression recommendations and tracking
@Observable
@MainActor
final class ProgressionCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    private let container: DependencyContainer
    private(set) var progressionDashboardViewModel: ProgressionDashboardViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        progressionDashboardViewModel = makeProgressionDashboardViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        ProgressionCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func destinationView(for destination: ProgressionDestination) -> some View {
        switch destination {
        case .exerciseProgression(let exerciseName):
            ExerciseProgressionView(
                viewModel: makeExerciseProgressionViewModel(exerciseName: exerciseName),
                coordinator: self
            )
        }
    }
    
    // MARK: - Navigation Actions
    
    func showExerciseProgression(exerciseName: String) {
        navigationPath.append(ProgressionDestination.exerciseProgression(exerciseName: exerciseName))
    }
    
    // MARK: - ViewModel Factories
    
    private func makeProgressionDashboardViewModel() -> ProgressionDashboardViewModel {
        ProgressionDashboardViewModel(
            progressionRecommendationUseCase: container.progressionUseCaseFactory.makeProgressionRecommendationUseCase(),
            loadExerciseNames: { [container] in
                try container.progressionUseCaseFactory.loadTrackedExerciseNames()
            }
        )
    }
    
    private func makeExerciseProgressionViewModel(exerciseName: String) -> ExerciseProgressionViewModel {
        ExerciseProgressionViewModel(
            exerciseName: exerciseName,
            progressionRecommendationUseCase: container.progressionUseCaseFactory.makeProgressionRecommendationUseCase()
        )
    }
}

/// Navigation destinations for the Progression flow
enum ProgressionDestination: Hashable {
    case exerciseProgression(exerciseName: String)
}

private struct ProgressionCoordinatorContentView: View {
    @Bindable var coordinator: ProgressionCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.progressionDashboardViewModel {
                ProgressionDashboardView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: ProgressionDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
    }
}

/// View wrapper for ProgressionCoordinator
struct ProgressionCoordinatorView: View {
    let coordinator: ProgressionCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
