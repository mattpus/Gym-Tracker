import SwiftUI

/// Coordinator for the Settings tab
@Observable
@MainActor
final class SettingsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    private let container: DependencyContainer
    private(set) var settingsViewModel: SettingsViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        settingsViewModel = makeSettingsViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        SettingsCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func destinationView(for destination: SettingsDestination) -> some View {
        switch destination {
        case .appearance:
            AppearanceSettingsView()
        case .notifications:
            NotificationSettingsView()
        case .data:
            DataSettingsView()
        case .about:
            AboutView()
        }
    }
    
    // MARK: - Navigation Actions
    
    func showAppearanceSettings() {
        navigationPath.append(SettingsDestination.appearance)
    }
    
    func showNotificationSettings() {
        navigationPath.append(SettingsDestination.notifications)
    }
    
    func showDataSettings() {
        navigationPath.append(SettingsDestination.data)
    }
    
    func showAbout() {
        navigationPath.append(SettingsDestination.about)
    }
    
    // MARK: - ViewModel Factories
    
    private func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}

/// Navigation destinations for the Settings flow
enum SettingsDestination: Hashable {
    case appearance
    case notifications
    case data
    case about
}

/// Internal content view that uses @Bindable for navigation
private struct SettingsCoordinatorContentView: View {
    @Bindable var coordinator: SettingsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.settingsViewModel {
                SettingsView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: SettingsDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
    }
}

/// View wrapper for SettingsCoordinator
struct SettingsCoordinatorView: View {
    let coordinator: SettingsCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
