import Foundation

public protocol EmptyWorkoutStarting {
	func startEmptyWorkout(named name: String?, completion: @escaping (WorkoutScheduling.Result) -> Void)
}
