import Foundation

public protocol WorkoutDeleting {
	typealias Result = Swift.Result<Void, Error>
	
	func delete(workoutID: UUID, completion: @escaping (Result) -> Void)
}
