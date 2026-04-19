import Foundation

public struct Workout: Equatable, Hashable {
	public let id: UUID
	public let date: Date
	public let lastUpdatedAt: Date
	public let isFinished: Bool
	public let name: String
	public let notes: String?
	public let exercises: [Exercise]
	
	public init(
		id: UUID = UUID(),
		date: Date,
		lastUpdatedAt: Date? = nil,
		isFinished: Bool = true,
		name: String,
		notes: String? = nil,
		exercises: [Exercise]
	) {
		self.id = id
		self.date = date
		self.lastUpdatedAt = lastUpdatedAt ?? date
		self.isFinished = isFinished
		self.name = name
		self.notes = notes
		self.exercises = exercises
	}
	
	public var isEmpty: Bool {
		exercises.isEmpty
	}
}
