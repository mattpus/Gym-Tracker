import Foundation

public protocol WorkoutEditing {
	typealias Result = Swift.Result<Void, Error>
	
	func edit(_ workout: Workout, completion: @escaping (Result) -> Void)
}
