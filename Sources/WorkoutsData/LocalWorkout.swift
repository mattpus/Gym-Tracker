import Foundation
import WorkoutsDomain

public struct LocalWorkout: Equatable, Codable {
	public let id: UUID
	public let date: Date
	public let name: String
	public let notes: String?
	public let exercises: [LocalExercise]
	
	public init(id: UUID, date: Date, name: String, notes: String?, exercises: [LocalExercise]) {
		self.id = id
		self.date = date
		self.name = name
		self.notes = notes
		self.exercises = exercises
	}
}

public struct LocalExercise: Equatable, Codable {
	public let id: UUID
	public let name: String
	public let notes: String?
	public let sets: [LocalExerciseSet]
	
	public init(id: UUID, name: String, notes: String?, sets: [LocalExerciseSet]) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
	}
}

public struct LocalExerciseSet: Equatable, Codable {
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

extension Array where Element == Workout {
	func toLocal() -> [LocalWorkout] {
		return map { workout in
			LocalWorkout(
				id: workout.id,
				date: workout.date,
				name: workout.name,
				notes: workout.notes,
				exercises: workout.exercises.map { exercise in
					LocalExercise(
						id: exercise.id,
						name: exercise.name,
						notes: exercise.notes,
						sets: exercise.sets.map { set in
							LocalExerciseSet(
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

extension Array where Element == LocalWorkout {
	func toModels() -> [Workout] {
		return map { workout in
			Workout(
				id: workout.id,
				date: workout.date,
				name: workout.name,
				notes: workout.notes,
				exercises: workout.exercises.map { exercise in
					Exercise(
						id: exercise.id,
						name: exercise.name,
						notes: exercise.notes,
						sets: exercise.sets.map { set in
							ExerciseSet(
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
