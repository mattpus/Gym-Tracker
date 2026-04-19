import Foundation
import Observation

@Observable
@MainActor
final class SettingsRouter {
    let navigation: NavigationRouter
    private let container: DependencyContainer
    private(set) var settingsViewModel: SettingsViewModel

    init(container: DependencyContainer, navigation: NavigationRouter) {
        self.container = container
        self.navigation = navigation
        self.settingsViewModel = SettingsViewModel()
    }

    func showAppearanceSettings() {
        navigation.push(.appearanceSettings)
    }

    func showNotificationSettings() {
        navigation.push(.notificationSettings)
    }

    func showDataSettings() {
        navigation.push(.dataSettings)
    }

    func showAbout() {
        navigation.push(.about)
    }

    func makeDataSettingsViewModel() -> DataSettingsViewModel {
        DataSettingsViewModel(
            exportUseCase: container.workoutsUseCaseFactory.makeExportWorkoutHistoryCSVUseCase(),
            deleteHistoryUseCase: container.workoutsUseCaseFactory.makeDeleteWorkoutHistoryUseCase()
        )
    }
}
