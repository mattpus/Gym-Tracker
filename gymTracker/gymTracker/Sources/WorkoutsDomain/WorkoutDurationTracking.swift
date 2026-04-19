import Foundation

public protocol WorkoutDurationTracking {
	func start(workoutID: UUID, tick: @escaping (TimeInterval) -> Void)
	func stop(workoutID: UUID) -> TimeInterval?
}

public protocol WorkoutDurationScheduling {
	func scheduleRepeating(interval: TimeInterval, handler: @escaping () -> Void) -> CancellableTimer
}

public protocol CancellableTimer {
	func cancel()
}
