import Foundation

public struct Exercise: Equatable, Hashable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let sets: [ExerciseSet]
	public let supersetID: UUID?
	public let supersetOrder: Int?

	public init(
		id: UUID = UUID(),
		name: String,
		notes: String? = nil,
		sets: [ExerciseSet],
		supersetID: UUID? = nil,
		supersetOrder: Int? = nil
	) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
		self.supersetID = supersetID
		self.supersetOrder = supersetOrder
	}

	public init(
		id: UUID = UUID(),
		name: String,
		notes: String? = nil,
		sets: [ExerciseSet]
	) {
		self.init(id: id, name: name, notes: notes, sets: sets, supersetID: nil, supersetOrder: nil)
	}
	
	public var isCompleted: Bool {
		!sets.isEmpty
	}
}
