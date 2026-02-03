import SwiftUI

@main
struct GymTrackerApp: App {
    @State private var appCoordinator: AppCoordinator
    
    init() {
        let container = DependencyContainer()
        _appCoordinator = State(initialValue: AppCoordinator(container: container))
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
}
