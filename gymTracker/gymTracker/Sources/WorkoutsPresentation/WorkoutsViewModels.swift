import Foundation

public struct WorkoutsViewModel: Equatable {
	public let workouts: [Workout]
	
	public init(workouts: [Workout]) {
		self.workouts = workouts
	}
}

public struct WorkoutsLoadingViewModel: Equatable {
	public let isLoading: Bool
	
	public init(isLoading: Bool) {
		self.isLoading = isLoading
	}
}

public struct WorkoutsErrorViewModel: Equatable {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
}

public struct WorkoutCommandResultViewModel: Equatable {
	public let message: String
	
	public init(message: String) {
		self.message = message
	}
}

public struct WorkoutCommandLoadingViewModel: Equatable {
	public let isLoading: Bool
	
	public init(isLoading: Bool) {
		self.isLoading = isLoading
	}
}

public struct ExerciseSetLoggingViewModel: Equatable {
	public enum Action: Equatable {
		case added
		case updated
		case deleted
	}

	public let workout: Workout
	public let exercise: Exercise
	public let set: ExerciseSet?
	public let previousSet: ExerciseSet?
	public let action: Action
	public let previousDisplay: String

	public init(
		workout: Workout,
		exercise: Exercise,
		set: ExerciseSet?,
		previousSet: ExerciseSet?,
		action: Action,
		previousDisplay: String
	) {
		self.workout = workout
		self.exercise = exercise
		self.set = set
		self.previousSet = previousSet
		self.action = action
		self.previousDisplay = previousDisplay
	}
}

public struct ExerciseNotesViewModel: Equatable {
	public let exerciseID: UUID
	public let notes: String
	public let placeholder: String

	public init(exerciseID: UUID, notes: String, placeholder: String) {
		self.exerciseID = exerciseID
		self.notes = notes
		self.placeholder = placeholder
	}
}

public struct ExerciseActionMenuViewModel: Equatable {
	public let exerciseID: UUID
	public let items: [ExerciseActionMenuItemViewModel]

	public init(exerciseID: UUID, items: [ExerciseActionMenuItemViewModel]) {
		self.exerciseID = exerciseID
		self.items = items
	}
}

public struct ExerciseActionMenuItemViewModel: Equatable {
	public enum Action: Equatable {
		case reorder
		case replace
		case removeFromSuperset
		case removeExercise
	}

	public let action: Action
	public let title: String
	public let isEnabled: Bool

	public init(action: Action, title: String, isEnabled: Bool) {
		self.action = action
		self.title = title
		self.isEnabled = isEnabled
	}
}

public struct RoutinesViewModel: Equatable {
	public let routines: [RoutineCardViewModel]
	
	public init(routines: [RoutineCardViewModel]) {
		self.routines = routines
	}
}

public struct RoutineCardViewModel: Equatable {
	public let id: UUID
	public let name: String
	public let detail: String
	public let startButtonTitle: String
	
	public init(
		id: UUID,
		name: String,
		detail: String,
		startButtonTitle: String
	) {
		self.id = id
		self.name = name
		self.detail = detail
		self.startButtonTitle = startButtonTitle
	}
}

public struct RoutinesLoadingViewModel: Equatable {
	public let isLoading: Bool
	
	public init(isLoading: Bool) {
		self.isLoading = isLoading
	}
}

public struct RoutinesErrorViewModel: Equatable {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
}

public struct RoutineBuilderScreenViewModel: Equatable {
	public let title: String
	public let name: String
	public let isSaveEnabled: Bool
	public let exercises: [RoutineBuilderExerciseViewModel]
	
	public init(title: String, name: String, isSaveEnabled: Bool, exercises: [RoutineBuilderExerciseViewModel]) {
		self.title = title
		self.name = name
		self.isSaveEnabled = isSaveEnabled
		self.exercises = exercises
	}
}

public struct RoutineBuilderExerciseViewModel: Equatable {
	public let id: UUID
	public let name: String
	public let setsSummary: String
	
	public init(id: UUID, name: String, setsSummary: String) {
		self.id = id
		self.name = name
		self.setsSummary = setsSummary
	}
}

public struct RoutineSearchResultsViewModel: Equatable {
	public let items: [RoutineSearchItemViewModel]
	
	public init(items: [RoutineSearchItemViewModel]) {
		self.items = items
	}
}

public struct RoutineSearchItemViewModel: Equatable {
	public let id: UUID
	public let name: String
	public let subtitle: String
	
	public init(id: UUID, name: String, subtitle: String) {
		self.id = id
		self.name = name
		self.subtitle = subtitle
	}
}

public struct StartEmptyWorkoutPromptViewModel: Equatable {
	public let title: String
	public let placeholder: String
	
	public init(title: String, placeholder: String) {
		self.title = title
		self.placeholder = placeholder
	}
}

public struct WorkoutDurationViewModel: Equatable {
	public let formattedTime: String

	public init(formattedTime: String) {
		self.formattedTime = formattedTime
	}
}
