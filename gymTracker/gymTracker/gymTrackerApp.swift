//
//  gymTrackerApp.swift
//  gymTracker
//
//  Created by Matt on 18/04/2026.
//

import SwiftUI

@main
struct gymTrackerApp: App {
  
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
