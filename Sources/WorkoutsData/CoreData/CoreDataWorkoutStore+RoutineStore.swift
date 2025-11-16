import Foundation

extension CoreDataWorkoutStore: RoutineStore {
	public func retrieve() throws -> CachedRoutines? {
		try ManagedRoutineCache.find(in: context).map {
			CachedRoutines(routines: $0.localRoutines, timestamp: $0.timestamp)
		}
	}
	
	public func deleteCachedRoutines() throws {
		try ManagedRoutineCache.deleteCache(in: context)
	}
	
	public func insert(_ routines: [LocalRoutine], timestamp: Date) throws {
		let cache = try ManagedRoutineCache.newUniqueInstance(in: context)
		cache.timestamp = timestamp
		cache.routines = ManagedRoutine.routines(from: routines, in: context)
		try context.save()
	}
}
