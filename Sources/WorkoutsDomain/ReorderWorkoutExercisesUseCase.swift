import Foundation

public final class ReorderWorkoutExercisesUseCase: WorkoutExerciseReordering {
	public enum Error: Swift.Error {
		case workoutNotFound
		case invalidIndexes
	}

	private let repository: WorkoutRepository
	private let queue: DispatchQueue?

	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}

	public func reorderExercises(in workoutID: UUID, from sourceIndex: Int, to destinationIndex: Int, completion: @escaping (WorkoutExerciseReordering.Result) -> Void) {
		let action = { completion(self.reorder(workoutID: workoutID, sourceIndex: sourceIndex, destinationIndex: destinationIndex)) }

		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}

	private func reorder(workoutID: UUID, sourceIndex: Int, destinationIndex: Int) -> WorkoutExerciseReordering.Result {
		do {
			var workouts = try repository.loadWorkouts()
			guard let index = workouts.firstIndex(where: { $0.id == workoutID }) else {
				return .failure(Error.workoutNotFound)
			}
			var workout = workouts[index]
			guard workout.exercises.indices.contains(sourceIndex), workout.exercises.indices.contains(destinationIndex) else {
				return .failure(Error.invalidIndexes)
			}
			var exercises = workout.exercises
			let exercise = exercises.remove(at: sourceIndex)
			exercises.insert(exercise, at: destinationIndex)
			workout = Workout(id: workout.id, date: workout.date, name: workout.name, notes: workout.notes, exercises: exercises)
			workouts[index] = workout
			try repository.save(workouts)
			return .success(workout)
		} catch {
			return .failure(error)
		}
	}
}
