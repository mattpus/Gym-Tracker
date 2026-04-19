import Foundation

public struct ExerciseSetRequest: Equatable {
	public let type: ExerciseSetType?
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	public let isCompleted: Bool?
	
	public init(
		type: ExerciseSetType? = nil,
		repetitions: Int?,
		weight: Double?,
		duration: TimeInterval?,
		isCompleted: Bool? = nil
	) {
		self.type = type
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
		self.isCompleted = isCompleted
	}
}
