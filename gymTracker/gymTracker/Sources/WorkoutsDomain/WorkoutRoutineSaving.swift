import Foundation

public protocol WorkoutRoutineSaving {
	typealias Result = Swift.Result<Void, Swift.Error>
	
	func save(workout: Workout, as routineName: String?, completion: @escaping (Result) -> Void)
}
