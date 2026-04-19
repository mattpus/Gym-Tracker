import Foundation

public final class ScheduleWorkoutUseCase: WorkoutScheduling {
	private let repository: WorkoutRepository
	private let queue: DispatchQueue?
	
	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}
	
	public func schedule(_ workout: Workout, completion: @escaping (WorkoutScheduling.Result) -> Void) {
		let action = {
			completion(WorkoutScheduling.Result {
				var workouts = try self.repository.loadWorkouts()
				workouts.removeAll { $0.id == workout.id }
				workouts.append(workout)
				try self.repository.save(workouts)
				return workout
			})
		}
		
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}
}
