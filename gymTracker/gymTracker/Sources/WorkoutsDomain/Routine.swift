import Foundation

public struct Routine: Equatable, Hashable, Sendable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let exercises: [RoutineExercise]
	
	public init(
		id: UUID = UUID(),
		name: String,
		notes: String? = nil,
		exercises: [RoutineExercise]
	) {
		self.id = id
		self.name = name
		self.notes = notes
		self.exercises = exercises
	}
	
	public var isEmpty: Bool {
		exercises.isEmpty
	}
}
