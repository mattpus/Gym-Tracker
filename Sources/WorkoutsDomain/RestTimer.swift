import Foundation

public struct RestTimerConfiguration: Equatable {
	public let duration: TimeInterval
	public let exerciseID: UUID
	
	public init(duration: TimeInterval, exerciseID: UUID) {
		self.duration = duration
		self.exerciseID = exerciseID
	}
}

public struct RestTimerState: Equatable {
	public let exerciseID: UUID
	public let remaining: TimeInterval
	public let isRunning: Bool
	
	public init(exerciseID: UUID, remaining: TimeInterval, isRunning: Bool) {
		self.exerciseID = exerciseID
		self.remaining = remaining
		self.isRunning = isRunning
	}
}

public protocol RestTimerController {
	typealias TickHandler = (RestTimerState) -> Void
	
	func enable(for configuration: RestTimerConfiguration)
	func disable(exerciseID: UUID)
	func toggle(for exerciseID: UUID)
	func startIfEnabled(afterSetFor exerciseID: UUID)
	func cancel(exerciseID: UUID)
	func observe(_ handler: @escaping TickHandler)
}
