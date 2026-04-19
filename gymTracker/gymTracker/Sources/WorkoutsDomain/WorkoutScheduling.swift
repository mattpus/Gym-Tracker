import Foundation

public protocol WorkoutScheduling {
	typealias Result = Swift.Result<Workout, Error>
	
	func schedule(_ workout: Workout, completion: @escaping (Result) -> Void)
}
