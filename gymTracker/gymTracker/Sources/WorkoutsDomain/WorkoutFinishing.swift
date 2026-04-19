import Foundation

public protocol WorkoutFinishing {
	typealias FinishResult = Swift.Result<WorkoutSummary, Swift.Error>
	typealias DiscardResult = Swift.Result<Void, Swift.Error>
	
	func finish(workoutID: UUID, at endDate: Date, completion: @escaping (FinishResult) -> Void)
	func discard(workoutID: UUID, completion: @escaping (DiscardResult) -> Void)
}
