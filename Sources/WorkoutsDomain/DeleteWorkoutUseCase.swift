import Foundation

public final class DeleteWorkoutUseCase: WorkoutDeleting {
	private let repository: WorkoutRepository
	private let queue: DispatchQueue?
	
	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}
	
	public func delete(workoutID: UUID, completion: @escaping (WorkoutDeleting.Result) -> Void) {
		let action = {
			completion(WorkoutDeleting.Result {
				var workouts = try self.repository.loadWorkouts()
				workouts.removeAll(where: { $0.id == workoutID })
				try self.repository.save(workouts)
			})
		}
		
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}
}
