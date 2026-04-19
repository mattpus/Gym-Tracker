import Foundation

public final class StartRoutineUseCase: RoutineStarting {
	public enum Error: Swift.Error {
		case routineNotFound
	}
	
	private let routineRepository: RoutineRepository
	private let workoutScheduler: WorkoutScheduling
	private let currentDate: () -> Date
	private let uuid: () -> UUID
	
	public init(
		routineRepository: RoutineRepository,
		workoutScheduler: WorkoutScheduling,
		currentDate: @escaping () -> Date,
		uuid: @escaping () -> UUID
	) {
		self.routineRepository = routineRepository
		self.workoutScheduler = workoutScheduler
		self.currentDate = currentDate
		self.uuid = uuid
	}
	
	public func startRoutine(id routineID: UUID, completion: @escaping (WorkoutScheduling.Result) -> Void) {
		do {
			let routines = try routineRepository.loadRoutines()
			guard let routine = routines.first(where: { $0.id == routineID }) else {
				completion(.failure(Error.routineNotFound))
				return
			}
			
			let workout = makeWorkout(from: routine)
			workoutScheduler.schedule(workout, completion: completion)
		} catch {
			completion(.failure(error))
		}
	}
	
	private func makeWorkout(from routine: Routine) -> Workout {
		let exercises = routine.exercises.enumerated().map { index, exercise in
			let sets = exercise.sets.enumerated().map { order, set in
				ExerciseSet(
					id: uuid(),
					order: order,
					type: set.type,
					repetitions: set.repetitions,
					weight: set.weight,
					duration: set.duration,
					isCompleted: false
				)
			}
			
			return Exercise(
				id: exercise.id,
				name: exercise.name,
				notes: exercise.notes,
				sets: sets
			)
		}
		
		return Workout(
			id: uuid(),
			date: currentDate(),
			lastUpdatedAt: currentDate(),
			isFinished: false,
			name: routine.name,
			notes: routine.notes,
			exercises: exercises
		)
	}
}
