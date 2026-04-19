import Foundation

import CoreData

extension CoreDataWorkoutStore: WorkoutStore {
	public func insert(_ workouts: [LocalWorkout], timestamp: Date) throws {
		let managedCache = try ManagedWorkoutCache.newUniqueInstance(in: context)
		managedCache.timestamp = timestamp
		managedCache.workouts = ManagedWorkout.workouts(from: workouts, in: context)
		try context.save()
	}
	
	public func retrieve() throws -> CachedWorkouts? {
		try ManagedWorkoutCache.find(in: context).map {
			CachedWorkouts(workouts: $0.localWorkouts, timestamp: $0.timestamp)
		}
	}
	
	public func deleteCachedWorkouts() throws {
		try ManagedWorkoutCache.deleteCache(in: context)
	}
}
