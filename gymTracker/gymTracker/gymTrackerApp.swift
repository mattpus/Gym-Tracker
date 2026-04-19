//
//  gymTrackerApp.swift
//  gymTracker
//
//  Created by Matt on 18/04/2026.
//

import SwiftUI

@main
struct gymTrackerApp: App {
    @State private var router: MainRouter

    init() {
        let container = DependencyContainer()
        _router = State(initialValue: MainRouter(container: container))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(router: router)
        }
    }
}
