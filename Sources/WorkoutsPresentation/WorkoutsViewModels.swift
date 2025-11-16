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
