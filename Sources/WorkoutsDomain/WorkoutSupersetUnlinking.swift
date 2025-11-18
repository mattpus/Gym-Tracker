import Foundation

public protocol WorkoutSupersetUnlinking {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func removeExerciseFromSuperset(in workoutID: UUID, exerciseID: UUID, completion: @escaping (Result) -> Void)
}
