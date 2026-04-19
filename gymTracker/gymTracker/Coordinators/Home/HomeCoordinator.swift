import SwiftUI
import Observation

/// Coordinator for the Home tab - quick actions and recent activity
@Observable
@MainActor
final class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    private let container: DependencyContainer
    private(set) var homeViewModel: HomeViewModel?
    private(set) var workoutsCoordinator: WorkoutsCoordinator?
    private(set) var exerciseLibraryCoordinator: ExerciseLibraryCoordinator?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        homeViewModel = makeHomeViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        HomeCoordinatorContentView(coordinator: self)
    }

    @ViewBuilder
    func destinationView(for destination: HomeDestination) -> some View {
        switch destination {
        case .workouts:
            if let workoutsCoordinator {
                WorkoutsCoordinatorView(coordinator: workoutsCoordinator)
            }
        case .exerciseLibrary:
            if let exerciseLibraryCoordinator {
                ExerciseLibraryCoordinatorView(coordinator: exerciseLibraryCoordinator)
            }
        }
    }

    func showWorkouts() {
        if workoutsCoordinator == nil {
            let coordinator = WorkoutsCoordinator(container: container)
            coordinator.start()
            workoutsCoordinator = coordinator
            addChild(coordinator)
        }
        navigationPath.append(HomeDestination.workouts)
    }

    func startWorkout() {
        if workoutsCoordinator == nil {
            let coordinator = WorkoutsCoordinator(container: container)
            coordinator.start()
            workoutsCoordinator = coordinator
            addChild(coordinator)
        }
        navigationPath.append(HomeDestination.workouts)
        workoutsCoordinator?.startEmptyWorkout()
    }

    func showExerciseLibrary() {
        if exerciseLibraryCoordinator == nil {
            let coordinator = ExerciseLibraryCoordinator(container: container)
            coordinator.start()
            exerciseLibraryCoordinator = coordinator
            addChild(coordinator)
        }
        navigationPath.append(HomeDestination.exerciseLibrary)
    }

    func showWorkoutDetail(_ workoutId: UUID) {
        if workoutsCoordinator == nil {
            let coordinator = WorkoutsCoordinator(container: container)
            coordinator.start()
            workoutsCoordinator = coordinator
            addChild(coordinator)
        }
        navigationPath.append(HomeDestination.workouts)
        workoutsCoordinator?.showWorkoutDetail(workoutId: workoutId)
    }
    
    // MARK: - ViewModel Factories
    
    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase()
        )
    }
}

/// Internal content view that uses @Bindable for navigation
private struct HomeCoordinatorContentView: View {
    @Bindable var coordinator: HomeCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.homeViewModel {
                HomeView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: HomeDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
    }
}

enum HomeDestination: Hashable {
    case workouts
    case exerciseLibrary
}

/// View wrapper for HomeCoordinator
struct HomeCoordinatorView: View {
    let coordinator: HomeCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
