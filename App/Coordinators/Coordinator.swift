import SwiftUI

/// Base protocol for all coordinators in the app.
/// Coordinators handle navigation logic and create view models with injected dependencies.
@MainActor
protocol Coordinator: AnyObject, Observable {
    associatedtype RootView: View
    
    /// Child coordinators managed by this coordinator
    var childCoordinators: [any Coordinator] { get set }
    
    /// Start the coordinator flow
    func start()
    
    /// Build the root view for this coordinator
    @ViewBuilder
    func rootView() -> RootView
}

extension Coordinator {
    /// Add a child coordinator
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Remove a child coordinator
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    /// Remove all child coordinators
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}

/// Enumeration of possible navigation destinations within the app
enum AppDestination: Hashable {
    // Workouts
    case workoutDetail(id: UUID)
    case activeWorkout(id: UUID)
    case routineSelection
    case exerciseSelection
    
    // Exercise Library
    case exerciseDetail(id: UUID)
    case addCustomExercise
    
    // Analytics
    case workoutFrequency
    case muscleDistribution
    case weightProgression(exerciseId: UUID)
    case volumeProgression
    
    // Progression
    case exerciseProgression(exerciseId: UUID)
    
    // Settings
    case settingsDetail(section: SettingsSection)
}

enum SettingsSection: Hashable {
    case account
    case notifications
    case appearance
    case data
    case about
}
