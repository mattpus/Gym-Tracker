import Foundation

public final class LoadWorkoutsUseCase: WorkoutsLoading {
	private let repository: WorkoutRepository
	private let queue: DispatchQueue?
	
	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}
	
	public func load(completion: @escaping (WorkoutsLoading.Result) -> Void) {
		let execute = { completion(WorkoutsLoading.Result { try self.repository.loadWorkouts() }) }
		
		if let queue {
			queue.async(execute: execute)
		} else {
			execute()
		}
	}
}
