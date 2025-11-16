import Foundation

public struct ExerciseSetLogResult: Equatable {
	public let workout: Workout
	public let exercise: Exercise
	public let set: ExerciseSet
	public let previousSet: ExerciseSet?
	
	public init(workout: Workout, exercise: Exercise, set: ExerciseSet, previousSet: ExerciseSet?) {
		self.workout = workout
		self.exercise = exercise
		self.set = set
		self.previousSet = previousSet
	}
}

public struct ExerciseSetDeletionResult: Equatable {
	public let workout: Workout
	public let exercise: Exercise
	
	public init(workout: Workout, exercise: Exercise) {
		self.workout = workout
		self.exercise = exercise
	}
}
