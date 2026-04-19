import Foundation

public final class EditWorkoutUseCase: WorkoutEditing {
	private let repository: WorkoutRepository
	private let queue: DispatchQueue?
	
	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}
	
	public func edit(_ workout: Workout, completion: @escaping (WorkoutEditing.Result) -> Void) {
		let action = {
			completion(WorkoutEditing.Result {
				var workouts = try self.repository.loadWorkouts()
				let updatedWorkout = Workout(
					id: workout.id,
					date: workout.date,
					lastUpdatedAt: Date(),
					isFinished: workout.isFinished,
					name: workout.name,
					notes: workout.notes,
					exercises: workout.exercises
				)
				if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
					workouts[index] = updatedWorkout
				} else {
					workouts.append(updatedWorkout)
				}
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
