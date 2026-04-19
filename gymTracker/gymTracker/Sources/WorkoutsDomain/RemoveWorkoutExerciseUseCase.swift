import Foundation

public final class RemoveWorkoutExerciseUseCase: WorkoutExerciseRemoving {
	public enum Error: Swift.Error {
		case workoutNotFound
		case exerciseNotFound
		case lastExerciseRemovalNotAllowed
	}

	private let repository: WorkoutRepository
	private let queue: DispatchQueue?

	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}

	public func removeExercise(in workoutID: UUID, exerciseID: UUID, completion: @escaping (WorkoutExerciseRemoving.Result) -> Void) {
		let action = { completion(self.remove(workoutID: workoutID, exerciseID: exerciseID)) }
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}

	private func remove(workoutID: UUID, exerciseID: UUID) -> WorkoutExerciseRemoving.Result {
		do {
			var workouts = try repository.loadWorkouts()
			guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
				return .failure(Error.workoutNotFound)
			}
			var workout = workouts[workoutIndex]
			guard let exerciseIndex = workout.exercises.firstIndex(where: { $0.id == exerciseID }) else {
				return .failure(Error.exerciseNotFound)
			}
			guard workout.exercises.count > 1 else {
				return .failure(Error.lastExerciseRemovalNotAllowed)
			}
			var exercises = workout.exercises
			exercises.remove(at: exerciseIndex)
			workout = Workout(id: workout.id, date: workout.date, name: workout.name, notes: workout.notes, exercises: exercises)
			workouts[workoutIndex] = workout
			try repository.save(workouts)
			return .success(workout)
		} catch {
			return .failure(error)
		}
	}
}
