import Foundation

public struct ExerciseSet: Equatable, Hashable {
	public let id: UUID
	public let order: Int
	public let type: ExerciseSetType
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	public let isCompleted: Bool
	
	public init(
		id: UUID = UUID(),
		order: Int,
		type: ExerciseSetType = .main,
		repetitions: Int? = nil,
		weight: Double? = nil,
		duration: TimeInterval? = nil,
		isCompleted: Bool = false
	) {
		self.id = id
		self.order = order
		self.type = type
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
		self.isCompleted = isCompleted
	}
	
	public var isTimedSet: Bool {
		duration != nil
	}
	
	public var isWeightedSet: Bool {
		weight != nil
	}
}
