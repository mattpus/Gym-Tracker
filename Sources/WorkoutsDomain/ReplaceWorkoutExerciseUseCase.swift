import Foundation

public final class ReplaceWorkoutExerciseUseCase: WorkoutExerciseReplacing {
	public enum Error: Swift.Error {
		case workoutNotFound
		case exerciseNotFound
	}

	private let repository: WorkoutRepository
	private let queue: DispatchQueue?

	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil) {
		self.repository = repository
		self.queue = queue
	}

	public func replaceExercise(
		in workoutID: UUID,
		existingExerciseID: UUID,
		with newExercise: ExerciseLibraryItem,
		completion: @escaping (WorkoutExerciseReplacing.Result) -> Void
	) {
		let action = { completion(self.replace(workoutID: workoutID, existingExerciseID: existingExerciseID, newExercise: newExercise)) }
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}

	private func replace(workoutID: UUID, existingExerciseID: UUID, newExercise: ExerciseLibraryItem) -> WorkoutExerciseReplacing.Result {
		do {
			var workouts = try repository.loadWorkouts()
			guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
				return .failure(Error.workoutNotFound)
			}
			var workout = workouts[workoutIndex]
			guard let exerciseIndex = workout.exercises.firstIndex(where: { $0.id == existingExerciseID }) else {
				return .failure(Error.exerciseNotFound)
			}
			var exercises = workout.exercises
			let replaced = Exercise(
				id: newExercise.id,
				name: newExercise.name,
				notes: newExercise.primaryMuscle,
				sets: []
			)
			exercises[exerciseIndex] = replaced
			workout = Workout(id: workout.id, date: workout.date, name: workout.name, notes: workout.notes, exercises: exercises)
			workouts[workoutIndex] = workout
			try repository.save(workouts)
			return .success(workout)
		} catch {
			return .failure(error)
		}
	}
}
