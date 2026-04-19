import Foundation

public struct LocalWorkout: Equatable, Codable {
	public let id: UUID
	public let date: Date
	public let lastUpdatedAt: Date
	public let isFinished: Bool
	public let name: String
	public let notes: String?
	public let exercises: [LocalExercise]
	
	public init(id: UUID, date: Date, lastUpdatedAt: Date, isFinished: Bool, name: String, notes: String?, exercises: [LocalExercise]) {
		self.id = id
		self.date = date
		self.lastUpdatedAt = lastUpdatedAt
		self.isFinished = isFinished
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
	public let supersetID: UUID?
	public let supersetOrder: Int?
	
	public init(id: UUID, name: String, notes: String?, sets: [LocalExerciseSet], supersetID: UUID?, supersetOrder: Int?) {
		self.id = id
		self.name = name
		self.notes = notes
		self.sets = sets
		self.supersetID = supersetID
		self.supersetOrder = supersetOrder
	}
}

public struct LocalExerciseSet: Equatable, Codable {
	public let id: UUID
	public let order: Int
	public let type: ExerciseSetType
	public let repetitions: Int?
	public let weight: Double?
	public let duration: TimeInterval?
	public let isCompleted: Bool
	
	public init(
		id: UUID,
		order: Int,
		type: ExerciseSetType,
		repetitions: Int?,
		weight: Double?,
		duration: TimeInterval?,
		isCompleted: Bool
	) {
		self.id = id
		self.order = order
		self.type = type
		self.repetitions = repetitions
		self.weight = weight
		self.duration = duration
		self.isCompleted = isCompleted
	}
}

extension Array where Element == Workout {
	func toLocal() -> [LocalWorkout] {
		return map { workout in
			LocalWorkout(
				id: workout.id,
				date: workout.date,
				lastUpdatedAt: workout.lastUpdatedAt,
				isFinished: workout.isFinished,
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
								type: set.type,
								repetitions: set.repetitions,
								weight: set.weight,
								duration: set.duration,
								isCompleted: set.isCompleted
							)
						},
						supersetID: exercise.supersetID,
						supersetOrder: exercise.supersetOrder
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
				lastUpdatedAt: workout.lastUpdatedAt,
				isFinished: workout.isFinished,
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
							type: set.type,
							repetitions: set.repetitions,
							weight: set.weight,
							duration: set.duration,
							isCompleted: set.isCompleted
						)
					},
						supersetID: exercise.supersetID,
						supersetOrder: exercise.supersetOrder
					)
				}
			)
		}
	}
}
