import Foundation

public struct WorkoutStats: Equatable {
	public let totalSets: Int
	public let totalVolume: Double
	public let duration: TimeInterval
	
	public init(totalSets: Int, totalVolume: Double, duration: TimeInterval) {
		self.totalSets = totalSets
		self.totalVolume = totalVolume
		self.duration = duration
	}
	
	public static func make(for workout: Workout, finishingAt endDate: Date) -> WorkoutStats {
		let sets = workout.exercises.flatMap(\.sets)
		let totalSets = sets.count
		let totalVolume = sets.reduce(0) { partialResult, set in
			let reps = Double(set.repetitions ?? 0)
			let weight = set.weight ?? 0
			return partialResult + reps * weight
		}
		let duration = max(0, endDate.timeIntervalSince(workout.date))
		return WorkoutStats(totalSets: totalSets, totalVolume: totalVolume, duration: duration)
	}
}

public struct WorkoutSummary: Equatable {
	public let workout: Workout
	public let stats: WorkoutStats
	
	public init(workout: Workout, stats: WorkoutStats) {
		self.workout = workout
		self.stats = stats
	}
}
