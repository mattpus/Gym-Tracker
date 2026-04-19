import Foundation

public protocol WorkoutStore {
	func insert(_ workouts: [LocalWorkout], timestamp: Date) throws
	func retrieve() throws -> CachedWorkouts?
	func deleteCachedWorkouts() throws
}

public struct CachedWorkouts: Equatable {
	public let workouts: [LocalWorkout]
	public let timestamp: Date
	
	public init(workouts: [LocalWorkout], timestamp: Date) {
		self.workouts = workouts
		self.timestamp = timestamp
	}
}
