import SwiftUI

/// Represents the available tabs in the app
enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case workouts
    case analytics
    case progression
    case settings
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .workouts: return "Workouts"
        case .analytics: return "Analytics"
        case .progression: return "Progress"
        case .settings: return "Settings"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .workouts: return "dumbbell.fill"
        case .analytics: return "chart.bar.fill"
        case .progression: return "arrow.up.right.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Coordinator that manages the tab bar and its child coordinators
@Observable
@MainActor
final class TabCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var selectedTab: AppTab = .home
    
    private let container: DependencyContainer
    
    // Feature coordinators for each tab
    private(set) var homeCoordinator: HomeCoordinator?
    private(set) var workoutsCoordinator: WorkoutsCoordinator?
    private(set) var analyticsCoordinator: AnalyticsCoordinator?
    private(set) var progressionCoordinator: ProgressionCoordinator?
    private(set) var settingsCoordinator: SettingsCoordinator?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        // Initialize all tab coordinators
        let home = HomeCoordinator(container: container)
        let workouts = WorkoutsCoordinator(container: container)
        let analytics = AnalyticsCoordinator(container: container)
        let progression = ProgressionCoordinator(container: container)
        let settings = SettingsCoordinator(container: container)
        
        homeCoordinator = home
        workoutsCoordinator = workouts
        analyticsCoordinator = analytics
        progressionCoordinator = progression
        settingsCoordinator = settings
        
        // Add as children
        addChild(home)
        addChild(workouts)
        addChild(analytics)
        addChild(progression)
        addChild(settings)
        
        // Start each coordinator
        home.start()
        workouts.start()
        analytics.start()
        progression.start()
        settings.start()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        TabCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            if let coordinator = homeCoordinator {
                HomeCoordinatorView(coordinator: coordinator)
            }
        case .workouts:
            if let coordinator = workoutsCoordinator {
                WorkoutsCoordinatorView(coordinator: coordinator)
            }
        case .analytics:
            if let coordinator = analyticsCoordinator {
                AnalyticsCoordinatorView(coordinator: coordinator)
            }
        case .progression:
            if let coordinator = progressionCoordinator {
                ProgressionCoordinatorView(coordinator: coordinator)
            }
        case .settings:
            if let coordinator = settingsCoordinator {
                SettingsCoordinatorView(coordinator: coordinator)
            }
        }
    }
}

/// Internal content view that uses @Bindable for tab selection
private struct TabCoordinatorContentView: View {
    @Bindable var coordinator: TabCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                coordinator.tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
    }
}

/// View wrapper for TabCoordinator
struct TabCoordinatorView: View {
    let coordinator: TabCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
