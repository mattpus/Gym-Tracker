import Foundation

public protocol WorkoutExerciseLibrarySearching {
	typealias Result = Swift.Result<[ExerciseLibraryItem], Error>
	
	func search(query: String, completion: @escaping (Result) -> Void)
}

public struct ExerciseLibraryItem: Equatable, Hashable {
	public let id: UUID
	public let name: String
	public let primaryMuscle: String?
	
	public init(id: UUID, name: String, primaryMuscle: String?) {
		self.id = id
		self.name = name
		self.primaryMuscle = primaryMuscle
	}
}
