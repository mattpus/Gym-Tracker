import Foundation

public struct Workout: Equatable, Hashable {
	public let id: UUID
	public let date: Date
	public let name: String
	public let notes: String?
	public let exercises: [Exercise]
	
	public init(
		id: UUID = UUID(),
		date: Date,
		name: String,
		notes: String? = nil,
		exercises: [Exercise]
	) {
		self.id = id
		self.date = date
		self.name = name
		self.notes = notes
		self.exercises = exercises
	}
	
	public var isEmpty: Bool {
		exercises.isEmpty
	}
}
