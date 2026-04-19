import Foundation

public final class UpdateExerciseNotesUseCase: ExerciseNotesUpdating {
	public enum Error: Swift.Error {
		case workoutNotFound
		case exerciseNotFound
	}

	private let repository: WorkoutRepository

	public init(repository: WorkoutRepository) {
		self.repository = repository
	}

	public func updateNotes(
		in workoutID: UUID,
		exerciseID: UUID,
		notes: String?,
		completion: @escaping (ExerciseNotesUpdating.Result) -> Void
	) {
		completion(ExerciseNotesUpdating.Result {
			var workouts = try repository.loadWorkouts()
			guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
				throw Error.workoutNotFound
			}
			let workout = workouts[workoutIndex]

			guard let exerciseIndex = workout.exercises.firstIndex(where: { $0.id == exerciseID }) else {
				throw Error.exerciseNotFound
			}

			var exercises = workout.exercises
			let exercise = exercises[exerciseIndex]
			let updatedExercise = Exercise(
				id: exercise.id,
				name: exercise.name,
				notes: notes,
				sets: exercise.sets,
				supersetID: exercise.supersetID,
				supersetOrder: exercise.supersetOrder
			)
			exercises[exerciseIndex] = updatedExercise

			let updatedWorkout = Workout(
				id: workout.id,
				date: workout.date,
				lastUpdatedAt: Date(),
				isFinished: workout.isFinished,
				name: workout.name,
				notes: workout.notes,
				exercises: exercises
			)
			workouts[workoutIndex] = updatedWorkout

			try repository.save(workouts)

			return updatedWorkout
		})
	}
}
