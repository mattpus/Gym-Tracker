import Foundation

public protocol WorkoutRepository {
	func save(_ workouts: [Workout]) throws
	func loadWorkouts() throws -> [Workout]
}
