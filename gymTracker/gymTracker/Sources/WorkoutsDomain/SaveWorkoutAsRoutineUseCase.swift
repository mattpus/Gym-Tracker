import Foundation

public final class SaveWorkoutAsRoutineUseCase: WorkoutRoutineSaving {
	private let repository: RoutineRepository
	private let queue: DispatchQueue?
	private let uuid: () -> UUID
	
	public init(repository: RoutineRepository, queue: DispatchQueue? = nil, uuid: @escaping () -> UUID = UUID.init) {
		self.repository = repository
		self.queue = queue
		self.uuid = uuid
	}
	
	public func save(workout: Workout, as routineName: String?, completion: @escaping (WorkoutRoutineSaving.Result) -> Void) {
		let action = { completion(self.save(workout: workout, as: routineName)) }
		
		if let queue {
			queue.async(execute: action)
		} else {
			action()
		}
	}
	
	private func save(workout: Workout, as routineName: String?) -> WorkoutRoutineSaving.Result {
		do {
			var routines = try repository.loadRoutines()
			let routine = Routine(
				id: uuid(),
				name: routineName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? routineName! : workout.name,
				notes: workout.notes,
				exercises: workout.exercises.enumerated().map { index, exercise in
					RoutineExercise(
						id: exercise.id,
						name: exercise.name,
						notes: exercise.notes,
						sets: makeRoutineSets(from: exercise.sets)
					)
				}
			)
			routines.append(routine)
			try repository.save(routines)
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	private func makeRoutineSets(from sets: [ExerciseSet]) -> [RoutineSet] {
		sets.enumerated().map { order, set in
			RoutineSet(
				id: uuid(),
				order: order,
				repetitions: set.repetitions,
				weight: set.weight,
				duration: set.duration
			)
		}
	}
}
