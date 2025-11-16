import CoreData

@objc(ManagedRoutineCache)
class ManagedRoutineCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var routines: NSOrderedSet
}

@objc(ManagedRoutine)
class ManagedRoutine: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var name: String
	@NSManaged var notes: String?
	@NSManaged var exercises: NSOrderedSet
	@NSManaged var cache: ManagedRoutineCache
}

@objc(ManagedRoutineExercise)
class ManagedRoutineExercise: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var name: String
	@NSManaged var notes: String?
	@NSManaged var sets: NSOrderedSet
	@NSManaged var routine: ManagedRoutine
}

@objc(ManagedRoutineSet)
class ManagedRoutineSet: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var order: Int16
	@NSManaged var repetitions: NSNumber?
	@NSManaged var weight: NSNumber?
	@NSManaged var duration: NSNumber?
	@NSManaged var exercise: ManagedRoutineExercise
}

extension ManagedRoutineCache {
	static func find(in context: NSManagedObjectContext) throws -> ManagedRoutineCache? {
		let request = NSFetchRequest<ManagedRoutineCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	static func deleteCache(in context: NSManagedObjectContext) throws {
		try find(in: context).map(context.delete).map(context.save)
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedRoutineCache {
		try deleteCache(in: context)
		return ManagedRoutineCache(context: context)
	}
	
	var localRoutines: [LocalRoutine] {
		routines.compactMap { ($0 as? ManagedRoutine)?.local }
	}
}

extension ManagedRoutine {
	static func routines(from local: [LocalRoutine], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { routine -> ManagedRoutine in
			let managedRoutine = ManagedRoutine(context: context)
			managedRoutine.id = routine.id
			managedRoutine.name = routine.name
			managedRoutine.notes = routine.notes
			managedRoutine.exercises = ManagedRoutineExercise.exercises(from: routine.exercises, in: context)
			return managedRoutine
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalRoutine {
		LocalRoutine(
			id: id,
			name: name,
			notes: notes,
			exercises: exercises.compactMap { ($0 as? ManagedRoutineExercise)?.local }
		)
	}
}

extension ManagedRoutineExercise {
	static func exercises(from local: [LocalRoutineExercise], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { exercise -> ManagedRoutineExercise in
			let managedExercise = ManagedRoutineExercise(context: context)
			managedExercise.id = exercise.id
			managedExercise.name = exercise.name
			managedExercise.notes = exercise.notes
			managedExercise.sets = ManagedRoutineSet.sets(from: exercise.sets, in: context)
			return managedExercise
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalRoutineExercise {
		LocalRoutineExercise(
			id: id,
			name: name,
			notes: notes,
			sets: sets.compactMap { ($0 as? ManagedRoutineSet)?.local }
		)
	}
}

extension ManagedRoutineSet {
	static func sets(from local: [LocalRoutineSet], in context: NSManagedObjectContext) -> NSOrderedSet {
		let managed = local.map { set -> ManagedRoutineSet in
			let managedSet = ManagedRoutineSet(context: context)
			managedSet.id = set.id
			managedSet.order = Int16(set.order)
			managedSet.repetitions = set.repetitions.map { NSNumber(value: $0) }
			managedSet.weight = set.weight.map { NSNumber(value: $0) }
			managedSet.duration = set.duration.map { NSNumber(value: $0) }
			return managedSet
		}
		
		return NSOrderedSet(array: managed)
	}
	
	var local: LocalRoutineSet {
		LocalRoutineSet(
			id: id,
			order: Int(order),
			repetitions: repetitions?.intValue,
			weight: weight?.doubleValue,
			duration: duration?.doubleValue
		)
	}
}
