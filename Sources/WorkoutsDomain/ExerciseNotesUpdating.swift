import Foundation

public protocol ExerciseNotesUpdating {
	typealias Result = Swift.Result<Workout, Swift.Error>

	func updateNotes(
		in workoutID: UUID,
		exerciseID: UUID,
		notes: String?,
		completion: @escaping (Result) -> Void
	)
}
