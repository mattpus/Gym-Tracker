import Foundation

public protocol WorkoutExerciseRemoving {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func removeExercise(in workoutID: UUID, exerciseID: UUID, completion: @escaping (Result) -> Void)
}
