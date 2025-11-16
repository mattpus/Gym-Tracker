import Foundation

public struct Exercise: Equatable, Hashable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let sets: [ExerciseSet]
	
	public init(
		id: UUID = UUID(),
		name: String,
		notes: String? = nil,
		sets: [ExerciseSet]
	) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
	}
	
	public var isCompleted: Bool {
		!sets.isEmpty
	}
}
