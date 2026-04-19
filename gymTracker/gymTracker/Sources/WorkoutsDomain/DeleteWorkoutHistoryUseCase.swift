import Foundation

public protocol WorkoutHistoryDeleting {
	typealias Result = Swift.Result<Void, Error>

	func deleteAllHistory(completion: @escaping (Result) -> Void)
}

public final class DeleteWorkoutHistoryUseCase: WorkoutHistoryDeleting {
	private let repository: WorkoutRepository

	public init(repository: WorkoutRepository) {
		self.repository = repository
	}

	public func deleteAllHistory(completion: @escaping (WorkoutHistoryDeleting.Result) -> Void) {
		completion(WorkoutHistoryDeleting.Result {
			try repository.save([])
		})
	}
}
