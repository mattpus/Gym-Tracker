import Foundation

public protocol WorkoutScheduling {
	typealias Result = Swift.Result<Void, Error>
	
	func schedule(_ workout: Workout, completion: @escaping (Result) -> Void)
}
