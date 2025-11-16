import Foundation
import WorkoutsDomain

public struct LocalRoutine: Equatable, Codable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let exercises: [LocalRoutineExercise]
	
	public init(id: UUID, name: String, notes: String?, exercises: [LocalRoutineExercise]) {
		self.id = id
		self.name = name
		self.notes = notes
		self.exercises = exercises
	}
}

public struct LocalRoutineExercise: Equatable, Codable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let sets: [LocalRoutineSet]
	
	public init(id: UUID, name: String, notes: String?, sets: [LocalRoutineSet]) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
	}
}

public struct LocalRoutineSet: Equatable, Codable {
	public let id: UUID
	public let order: Int
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	
	public init(
		id: UUID,
		order: Int,
		repetitions: Int?,
		weight: Double?,
		duration: TimeInterval?
	) {
		self.id = id
		self.order = order
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
	}
}

extension Array where Element == Routine {
	func toLocalRoutines() -> [LocalRoutine] {
		map { routine in
			LocalRoutine(
				id: routine.id,
				name: routine.name,
				notes: routine.notes,
				exercises: routine.exercises.map { exercise in
					LocalRoutineExercise(
						id: exercise.id,
						name: exercise.name,
						notes: exercise.notes,
						sets: exercise.sets.map { set in
							LocalRoutineSet(
								id: set.id,
								order: set.order,
								repetitions: set.repetitions,
								weight: set.weight,
								duration: set.duration
							)
						}
					)
				}
			)
		}
	}
}

extension Array where Element == LocalRoutine {
	func toRoutineModels() -> [Routine] {
		map { routine in
			Routine(
				id: routine.id,
				name: routine.name,
				notes: routine.notes,
				exercises: routine.exercises.map { exercise in
					RoutineExercise(
						id: exercise.id,
						name: exercise.name,
						notes: exercise.notes,
						sets: exercise.sets.map { set in
							RoutineSet(
								id: set.id,
								order: set.order,
								repetitions: set.repetitions,
								weight: set.weight,
								duration: set.duration
							)
						}
					)
				}
			)
		}
	}
}
