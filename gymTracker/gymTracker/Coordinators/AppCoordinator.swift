import SwiftUI
import Observation

/// Root coordinator that manages the app's lifecycle and main navigation structure
@Observable
@MainActor
final class AppCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    
    private let container: DependencyContainer
    private(set) var tabCoordinator: TabCoordinator?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        guard tabCoordinator == nil else { return }

        let tabCoordinator = TabCoordinator(container: container)
        self.tabCoordinator = tabCoordinator
        addChild(tabCoordinator)
        tabCoordinator.start()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        if let tabCoordinator {
            TabCoordinatorView(coordinator: tabCoordinator)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// View wrapper for AppCoordinator
struct AppCoordinatorView: View {
    let coordinator: AppCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
