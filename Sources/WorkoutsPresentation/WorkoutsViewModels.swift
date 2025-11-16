import Foundation
import WorkoutsDomain

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
	
	public init(
		workout: Workout,
		exercise: Exercise,
		set: ExerciseSet?,
		previousSet: ExerciseSet?,
		action: Action
	) {
		self.workout = workout
		self.exercise = exercise
		self.set = set
		self.previousSet = previousSet
		self.action = action
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

public struct RoutineBuilderViewModel: Equatable {
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
