import Foundation
@testable import WorkoutsDomain

final class WorkoutRepositorySpy: WorkoutRepository {
enum Message: Equatable {
	case load
	case save([Workout])
	
	var savedWorkouts: [Workout]? {
		if case let .save(workouts) = self {
			return workouts
		}
		return nil
	}
}
	
	private(set) var messages = [Message]()
	var loadResult: Result<[Workout], Error> = .success([])
	var saveResult: Error?
	
	func save(_ workouts: [Workout]) throws {
		messages.append(.save(workouts))
		if let error = saveResult {
			throw error
		}
	}
	
	func loadWorkouts() throws -> [Workout] {
		messages.append(.load)
		return try loadResult.get()
	}
}
