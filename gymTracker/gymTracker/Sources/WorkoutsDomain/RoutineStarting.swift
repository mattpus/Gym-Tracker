import Foundation

public protocol RoutineStarting {
	func startRoutine(id routineID: UUID, completion: @escaping (WorkoutScheduling.Result) -> Void)
}
