import Foundation

public final class LinkExercisesToSupersetUseCase: WorkoutSupersetLinking {
	public enum Error: Swift.Error {
		case workoutNotFound
		case insufficientExercises
		case exerciseNotFound
	}

	private let repository: WorkoutRepository
	private let queue: DispatchQueue?
	private let uuid: () -> UUID

	public init(repository: WorkoutRepository, queue: DispatchQueue? = nil, uuid: @escaping () -> UUID = UUID.init) {
		self.repository = repository
		self.queue = queue
		self.uuid = uuid
	}

	public func linkExercises(in workoutID: UUID, exerciseIDs: [UUID], supersetID: UUID? = nil, completion: @escaping (WorkoutSupersetLinking.Result) -> Void) {
		let action = { completion(self.link(workoutID: workoutID, exerciseIDs: exerciseIDs, supersetID: supersetID)) }
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}

	private func link(workoutID: UUID, exerciseIDs: [UUID], supersetID: UUID?) -> WorkoutSupersetLinking.Result {
		guard exerciseIDs.count >= 2 else { return .failure(Error.insufficientExercises) }
		do {
			var workouts = try repository.loadWorkouts()
			guard let workoutIndex = workouts.firstIndex(where: { $0.id == workoutID }) else {
				return .failure(Error.workoutNotFound)
			}
			var workout = workouts[workoutIndex]
			var exercises = workout.exercises
			let groupID = supersetID ?? uuid()
			for (order, targetID) in exerciseIDs.enumerated() {
				guard let index = exercises.firstIndex(where: { $0.id == targetID }) else {
					return .failure(Error.exerciseNotFound)
				}
				let exercise = exercises[index]
				exercises[index] = Exercise(
					id: exercise.id,
					name: exercise.name,
					notes: exercise.notes,
					sets: exercise.sets,
					supersetID: groupID,
					supersetOrder: order
				)
			}
			workout = Workout(id: workout.id, date: workout.date, name: workout.name, notes: workout.notes, exercises: exercises)
			workouts[workoutIndex] = workout
			try repository.save(workouts)
			return .success(workout)
		} catch {
			return .failure(error)
		}
	}
}
