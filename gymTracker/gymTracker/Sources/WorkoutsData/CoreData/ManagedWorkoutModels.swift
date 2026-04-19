import CoreData

@objc(ManagedWorkoutCache)
class ManagedWorkoutCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var workouts: NSOrderedSet
}

@objc(ManagedWorkout)
class ManagedWorkout: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var date: Date
	@NSManaged var lastUpdatedAt: Date
	@NSManaged var isFinished: Bool
	@NSManaged var name: String
	@NSManaged var notes: String?
	@NSManaged var exercises: NSOrderedSet
	@NSManaged var cache: ManagedWorkoutCache
}

@objc(ManagedExercise)
class ManagedExercise: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var name: String
	@NSManaged var notes: String?
	@NSManaged var sets: NSOrderedSet
	@NSManaged var workout: ManagedWorkout
	@NSManaged var supersetID: UUID?
	@NSManaged var supersetOrder: NSNumber?
}

@objc(ManagedExerciseSet)
class ManagedExerciseSet: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var order: Int16
	@NSManaged var type: String
	@NSManaged var repetitions: NSNumber?
	@NSManaged var weight: NSNumber?
	@NSManaged var duration: NSNumber?
	@NSManaged var isCompleted: Bool
	@NSManaged var exercise: ManagedExercise
}

extension ManagedWorkoutCache {
	static func find(in context: NSManagedObjectContext) throws -> ManagedWorkoutCache? {
		let request = NSFetchRequest<ManagedWorkoutCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	static func deleteCache(in context: NSManagedObjectContext) throws {
		try find(in: context).map(context.delete).map(context.save)
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedWorkoutCache {
		try deleteCache(in: context)
		return ManagedWorkoutCache(context: context)
	}
	
	var localWorkouts: [LocalWorkout] {
		workouts.compactMap { ($0 as? ManagedWorkout)?.local }
	}
	
}

extension ManagedWorkout {
	static func workouts(from local: [LocalWorkout], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { workout -> ManagedWorkout in
			let managedWorkout = ManagedWorkout(context: context)
			managedWorkout.id = workout.id
			managedWorkout.date = workout.date
			managedWorkout.lastUpdatedAt = workout.lastUpdatedAt
			managedWorkout.isFinished = workout.isFinished
			managedWorkout.name = workout.name
			managedWorkout.notes = workout.notes
			managedWorkout.exercises = ManagedExercise.exercises(from: workout.exercises, in: context)
			return managedWorkout
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalWorkout {
		return LocalWorkout(
			id: id,
			date: date,
			lastUpdatedAt: lastUpdatedAt,
			isFinished: isFinished,
			name: name,
			notes: notes,
			exercises: exercises.compactMap { ($0 as? ManagedExercise)?.local }
		)
	}
}

extension ManagedExercise {
	static func exercises(from local: [LocalExercise], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { exercise -> ManagedExercise in
			let managedExercise = ManagedExercise(context: context)
			managedExercise.id = exercise.id
			managedExercise.name = exercise.name
			managedExercise.notes = exercise.notes
			managedExercise.supersetID = exercise.supersetID
			managedExercise.supersetOrder = exercise.supersetOrder.map { NSNumber(value: $0) }
			managedExercise.sets = ManagedExerciseSet.sets(from: exercise.sets, in: context)
			return managedExercise
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalExercise {
		return LocalExercise(
			id: id,
			name: name,
			notes: notes,
			sets: sets.compactMap { ($0 as? ManagedExerciseSet)?.local },
			supersetID: supersetID,
			supersetOrder: supersetOrder?.intValue
		)
	}
}

extension ManagedExerciseSet {
	static func sets(from local: [LocalExerciseSet], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { set -> ManagedExerciseSet in
			let managedSet = ManagedExerciseSet(context: context)
			managedSet.id = set.id
			managedSet.order = Int16(set.order)
			managedSet.type = set.type.rawValue
			managedSet.repetitions = set.repetitions.map { NSNumber(value: $0) }
			managedSet.weight = set.weight.map { NSNumber(value: $0) }
			managedSet.duration = set.duration.map { NSNumber(value: $0) }
			managedSet.isCompleted = set.isCompleted
			return managedSet
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalExerciseSet {
		LocalExerciseSet(
			id: id,
			order: Int(order),
			type: ExerciseSetType(rawValue: type) ?? .main,
			repetitions: repetitions?.intValue,
			weight: weight?.doubleValue,
			duration: duration?.doubleValue,
			isCompleted: isCompleted
		)
	}
}
