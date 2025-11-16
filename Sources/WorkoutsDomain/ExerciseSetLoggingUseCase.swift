import Foundation

public final class ExerciseSetLoggingUseCase: ExerciseSetLogging {
	public enum Error: Swift.Error {
		case workoutNotFound
		case exerciseNotFound
		case setNotFound
	}
	
	private let repository: WorkoutRepository
	
	public init(repository: WorkoutRepository) {
		self.repository = repository
	}
	
	public func addSet(to workoutID: UUID, exerciseID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion) {
		completion(Swift.Result {
			var workouts = try self.repository.loadWorkouts()
			let (workoutIndex, exerciseIndex) = try self.indexes(for: workoutID, exerciseID: exerciseID, in: workouts)
			
			let workout = workouts[workoutIndex]
			let exercise = workout.exercises[exerciseIndex]
			let nextOrder = (exercise.sets.map(\.order).max() ?? -1) + 1
			let newSet = ExerciseSet(
				order: nextOrder,
				repetitions: request.repetitions,
				weight: request.weight,
				duration: request.duration
			)
			
			let updatedExercise = self.updatedExercise(from: exercise, replacingSets: exercise.sets + [newSet])
			let updatedWorkout = self.updatedWorkout(from: workout, replacingExerciseAt: exerciseIndex, with: updatedExercise)
			workouts[workoutIndex] = updatedWorkout
			
			try self.repository.save(workouts)
			
			let previous = self.previousSet(for: exercise.id, before: workout.date, in: workouts)
			
			return ExerciseSetLogResult(workout: updatedWorkout, exercise: updatedExercise, set: newSet, previousSet: previous)
		})
	}
	
	public func updateSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion) {
		completion(Swift.Result {
			var workouts = try self.repository.loadWorkouts()
			let (workoutIndex, exerciseIndex) = try self.indexes(for: workoutID, exerciseID: exerciseID, in: workouts)
			let workout = workouts[workoutIndex]
			let exercise = workout.exercises[exerciseIndex]
			
			guard let setIndex = exercise.sets.firstIndex(where: { $0.id == setID }) else {
				throw Error.setNotFound
			}
			
			var sets = exercise.sets
			let set = sets[setIndex]
			let updatedSet = ExerciseSet(
				id: set.id,
				order: set.order,
				repetitions: request.repetitions,
				weight: request.weight,
				duration: request.duration
			)
			sets[setIndex] = updatedSet
			
			let updatedExercise = self.updatedExercise(from: exercise, replacingSets: sets)
			let updatedWorkout = self.updatedWorkout(from: workout, replacingExerciseAt: exerciseIndex, with: updatedExercise)
			workouts[workoutIndex] = updatedWorkout
			
			try self.repository.save(workouts)
			
			let previous = self.previousSet(for: exercise.id, before: workout.date, in: workouts)
			
			return ExerciseSetLogResult(workout: updatedWorkout, exercise: updatedExercise, set: updatedSet, previousSet: previous)
		})
	}
	
	public func deleteSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, completion: @escaping DeleteCompletion) {
		completion(Swift.Result {
			var workouts = try self.repository.loadWorkouts()
			let (workoutIndex, exerciseIndex) = try self.indexes(for: workoutID, exerciseID: exerciseID, in: workouts)
			let workout = workouts[workoutIndex]
			let exercise = workout.exercises[exerciseIndex]
			
			guard exercise.sets.contains(where: { $0.id == setID }) else {
				throw Error.setNotFound
			}
			
			let remainingSets = exercise.sets
				.filter { $0.id != setID }
				.enumerated()
				.map { index, set in
					ExerciseSet(
						id: set.id,
						order: index,
						repetitions: set.repetitions,
						weight: set.weight,
						duration: set.duration
					)
				}
			
			let updatedExercise = self.updatedExercise(from: exercise, replacingSets: remainingSets)
			let updatedWorkout = self.updatedWorkout(from: workout, replacingExerciseAt: exerciseIndex, with: updatedExercise)
			workouts[workoutIndex] = updatedWorkout
			
			try self.repository.save(workouts)
			
			return ExerciseSetDeletionResult(workout: updatedWorkout, exercise: updatedExercise)
		})
	}
	
	private func indexes(for workoutID: UUID, exerciseID: UUID, in workouts: [Workout]) throws -> (Int, Int) {
		guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
			throw Error.workoutNotFound
		}
		let workout = workouts[workoutIndex]
		guard let exerciseIndex = workout.exercises.firstIndex(where: { $0.id == exerciseID }) else {
			throw Error.exerciseNotFound
		}
		return (workoutIndex, exerciseIndex)
	}
	
	private func updatedExercise(from exercise: Exercise, replacingSets sets: [ExerciseSet]) -> Exercise {
		Exercise(id: exercise.id, name: exercise.name, notes: exercise.notes, sets: sets)
	}
	
	private func updatedWorkout(from workout: Workout, replacingExerciseAt index: Int, with exercise: Exercise) -> Workout {
		var exercises = workout.exercises
		exercises[index] = exercise
		return Workout(
			id: workout.id,
			date: workout.date,
			name: workout.name,
			notes: workout.notes,
			exercises: exercises
		)
	}
	
	private func previousSet(for exerciseID: UUID, before date: Date, in workouts: [Workout]) -> ExerciseSet? {
		return workouts
			.filter { $0.date < date }
			.sorted { $0.date > $1.date }
			.compactMap { workout in
				workout.exercises.first(where: { $0.id == exerciseID })?.sets.last
			}
			.first
	}
}
