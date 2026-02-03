import SwiftUI

/// Coordinator for the Home tab - quick actions and recent activity
@Observable
@MainActor
final class HomeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    private let container: DependencyContainer
    private(set) var homeViewModel: HomeViewModel?
    
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
            }
        }
    }
}

/// View wrapper for HomeCoordinator
struct HomeCoordinatorView: View {
    let coordinator: HomeCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
