import Foundation

public final class RemoveExerciseFromSupersetUseCase: WorkoutSupersetUnlinking {
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

	public func removeExerciseFromSuperset(in workoutID: UUID, exerciseID: UUID, completion: @escaping (WorkoutSupersetUnlinking.Result) -> Void) {
		let action = { completion(self.remove(workoutID: workoutID, exerciseID: exerciseID)) }
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}

	private func remove(workoutID: UUID, exerciseID: UUID) -> WorkoutSupersetUnlinking.Result {
		do {
			var workouts = try repository.loadWorkouts()
			guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
				return .failure(Error.workoutNotFound)
			}
			var workout = workouts[workoutIndex]
			guard let exerciseIndex = workout.exercises.firstIndex(where: { $0.id == exerciseID }) else {
				return .failure(Error.exerciseNotFound)
			}
			var exercises = workout.exercises
			let supersetID = exercises[exerciseIndex].supersetID
			exercises[exerciseIndex] = Exercise(
				id: exercises[exerciseIndex].id,
				name: exercises[exerciseIndex].name,
				notes: exercises[exerciseIndex].notes,
				sets: exercises[exerciseIndex].sets,
				supersetID: nil,
				supersetOrder: nil
			)
			if let supersetID {
				exercises = removeSupersetIfNeeded(from: exercises, supersetID: supersetID)
			}
			workout = Workout(id: workout.id, date: workout.date, name: workout.name, notes: workout.notes, exercises: exercises)
			workouts[workoutIndex] = workout
			try repository.save(workouts)
			return .success(workout)
		} catch {
			return .failure(error)
		}
	}
	
	private func removeSupersetIfNeeded(from exercises: [Exercise], supersetID: UUID) -> [Exercise] {
		let grouped = exercises.filter { $0.supersetID == supersetID }
		guard grouped.count > 1 else {
			return exercises.map { exercise in
				guard exercise.supersetID == supersetID else { return exercise }
				return Exercise(id: exercise.id, name: exercise.name, notes: exercise.notes, sets: exercise.sets, supersetID: nil, supersetOrder: nil)
			}
		}
		return exercises
	}
}
