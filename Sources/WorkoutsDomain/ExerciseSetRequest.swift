import Foundation

public struct ExerciseSetRequest: Equatable {
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	
	public init(
		repetitions: Int?,
		weight: Double?,
		duration: TimeInterval?
	) {
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
	}
}
