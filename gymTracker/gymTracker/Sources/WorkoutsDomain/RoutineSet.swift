import Foundation

public struct RoutineSet: Equatable, Hashable, Sendable {
	public let id: UUID
	public let order: Int
	public let type: ExerciseSetType
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	
	public init(
		id: UUID = UUID(),
		order: Int,
		type: ExerciseSetType = .main,
		repetitions: Int? = nil,
		weight: Double? = nil,
		duration: TimeInterval? = nil
	) {
		self.id = id
		self.order = order
		self.type = type
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
	}
	
	public var isTimed: Bool {
		duration != nil
	}
	
	public var isWeighted: Bool {
		weight != nil
	}
}
