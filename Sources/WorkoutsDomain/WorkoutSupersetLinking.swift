import Foundation

public protocol WorkoutSupersetLinking {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func linkExercises(
		in workoutID: UUID,
		exerciseIDs: [UUID],
		supersetID: UUID?,
		completion: @escaping (Result) -> Void
	)
}
