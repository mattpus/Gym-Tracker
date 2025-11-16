import Foundation

public struct RoutineExercise: Equatable, Hashable, Sendable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let sets: [RoutineSet]
	
	public init(
		id: UUID = UUID(),
		name: String,
		notes: String? = nil,
		sets: [RoutineSet]
	) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
	}
	
	public var hasConfiguredSets: Bool {
		!sets.isEmpty
	}
}
