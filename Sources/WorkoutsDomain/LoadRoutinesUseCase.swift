import Foundation

public final class LoadRoutinesUseCase: RoutinesLoading {
	private let repository: RoutineRepository
	private let queue: DispatchQueue?
	
	public init(repository: RoutineRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}
	
	public func load(completion: @escaping (RoutinesLoading.Result) -> Void) {
		let execute = {
			completion(RoutinesLoading.Result {
				try self.repository.loadRoutines()
			})
		}
		
		if let queue {
			queue.async(execute: execute)
		} else {
			execute()
		}
	}
}
