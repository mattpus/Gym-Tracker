import Foundation

public final class FinishWorkoutUseCase: WorkoutFinishing {
	public enum Error: Swift.Error {
		case workoutNotFound
	}
	
	private let repository: WorkoutRepository
	
	public init(repository: WorkoutRepository) {
		self.repository = repository
	}
	
	public func finish(workoutID: UUID, at endDate: Date, completion: @escaping (FinishResult) -> Void) {
		completion(FinishResult {
			let workouts = try repository.loadWorkouts()
			guard let index = workouts.firstIndex(where: { $0.id == workoutID }) else {
				throw Error.workoutNotFound
			}
			
			let workout = workouts[index]
			let stats = WorkoutStats.make(for: workout, finishingAt: endDate)
			try repository.save(workouts)
			
			return WorkoutSummary(workout: workout, stats: stats)
		})
	}
	
	public func discard(workoutID: UUID, completion: @escaping (DiscardResult) -> Void) {
		completion(DiscardResult {
			var workouts = try repository.loadWorkouts()
			guard let index = workouts.firstIndex(where: { $0.id == workoutID }) else {
				throw Error.workoutNotFound
			}
			
			workouts.remove(at: index)
			try repository.save(workouts)
		})
	}
}
