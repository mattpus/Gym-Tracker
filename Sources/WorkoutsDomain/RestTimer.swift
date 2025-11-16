import Foundation

public struct RestTimerConfiguration: Equatable, Sendable {
	public let duration: TimeInterval
	public let exerciseID: UUID
	
	public init(duration: TimeInterval, exerciseID: UUID) {
		self.duration = duration
		self.exerciseID = exerciseID
	}
}

public struct RestTimerState: Equatable, Sendable {
	public let exerciseID: UUID
	public let remaining: TimeInterval
	public let isRunning: Bool
	
	public init(exerciseID: UUID, remaining: TimeInterval, isRunning: Bool) {
		self.exerciseID = exerciseID
		self.remaining = remaining
		self.isRunning = isRunning
	}
}

public protocol RestTimerController: AnyObject, Sendable {
	typealias TickHandler = @Sendable (RestTimerState) async -> Void
	
	func enable(for configuration: RestTimerConfiguration) async
	func disable(exerciseID: UUID) async
	func toggle(for exerciseID: UUID) async
	func startIfEnabled(afterSetFor exerciseID: UUID) async
	func cancel(exerciseID: UUID) async
	func observe(_ handler: @escaping TickHandler) async
}
