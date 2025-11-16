import Foundation

public protocol ExerciseSetLogging {
	typealias LogCompletion = (Swift.Result<ExerciseSetLogResult, Swift.Error>) -> Void
	typealias DeleteCompletion = (Swift.Result<ExerciseSetDeletionResult, Swift.Error>) -> Void
	
	func addSet(to workoutID: UUID, exerciseID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion)
	func updateSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion)
	func deleteSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, completion: @escaping DeleteCompletion)
}
