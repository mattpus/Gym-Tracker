import Foundation

public struct RestTimerViewModel: Equatable {
	public let exerciseID: UUID
	public let remaining: TimeInterval
	public let isRunning: Bool
	
	public init(exerciseID: UUID, remaining: TimeInterval, isRunning: Bool) {
		self.exerciseID = exerciseID
		self.remaining = remaining
		self.isRunning = isRunning
	}
}

public struct RestTimerAlertViewModel: Equatable {
	public let exerciseID: UUID
	public let shouldPlayAlert: Bool
	
	public init(exerciseID: UUID, shouldPlayAlert: Bool) {
		self.exerciseID = exerciseID
		self.shouldPlayAlert = shouldPlayAlert
	}
}
