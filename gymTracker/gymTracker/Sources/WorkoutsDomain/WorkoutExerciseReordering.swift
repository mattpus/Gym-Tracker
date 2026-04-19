import Foundation

public protocol WorkoutExerciseReordering {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func reorderExercises(in workoutID: UUID, from sourceIndex: Int, to destinationIndex: Int, completion: @escaping (Result) -> Void)
}
