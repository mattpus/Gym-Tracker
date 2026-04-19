import Foundation

/// The presentation style for every navigation target in the app.
enum Destination: Hashable {
    case tab(AppTab)
    case push(PushDestination)
    case sheet(SheetDestination)
    case fullScreen(FullScreenDestination)
}

enum AppTab: Int, CaseIterable, Identifiable, Hashable {
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
        case .home: return "house"
        case .workouts: return "dumbbell"
        case .analytics: return "chart.bar"
        case .progression: return "arrow.up.right.circle"
        case .settings: return "gearshape"
        }
    }
}

enum PushDestination: Hashable {
    case exerciseLibrary
    case exerciseDetail(id: UUID)
    case workoutDetail(id: UUID)
    case workoutFrequency
    case muscleDistribution
    case weightProgression(exerciseName: String)
    case volumeProgression
    case recovery
    case exerciseProgression(exerciseName: String)
    case appearanceSettings
    case notificationSettings
    case dataSettings
    case about
}

enum SheetDestination: Hashable, Identifiable {
    case routineSelection
    case exerciseSelection(ExerciseSelectionContext)
    case routineBuilder
    case routineBuilderExerciseSelection
    case addCustomExercise
    case editCustomExercise(id: UUID)

    var id: String {
        switch self {
        case .routineSelection:
            return "routineSelection"
        case .exerciseSelection(let context):
            return "exerciseSelection-\(context.rawValue)"
        case .routineBuilder:
            return "routineBuilder"
        case .routineBuilderExerciseSelection:
            return "routineBuilderExerciseSelection"
        case .addCustomExercise:
            return "addCustomExercise"
        case .editCustomExercise(let id):
            return "editCustomExercise-\(id.uuidString)"
        }
    }
}

enum ExerciseSelectionContext: String, Hashable {
    case activeWorkout
    case routineBuilder
}

enum FullScreenDestination: Hashable, Identifiable {
    case activeWorkout(id: UUID)

    var id: String {
        switch self {
        case .activeWorkout(let id):
            return "activeWorkout-\(id.uuidString)"
        }
    }
}
