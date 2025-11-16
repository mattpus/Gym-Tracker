import Foundation

public protocol WorkoutExerciseReplacing {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func replaceExercise(
		in workoutID: UUID,
		existingExerciseID: UUID,
		with newExercise: ExerciseLibraryItem,
		completion: @escaping (Result) -> Void
	)
}
