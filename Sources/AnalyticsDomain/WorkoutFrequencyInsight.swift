import Foundation

public struct WorkoutFrequencyInsight: Equatable, Sendable {
    public let totalWorkouts: Int
    public let workoutsThisWeek: Int
    public let workoutsThisMonth: Int
    public let averageWorkoutsPerWeek: Double
    public let currentStreak: Int
    public let longestStreak: Int
    public let lastWorkoutDate: Date?
    public let daysSinceLastWorkout: Int?
    
    public init(
        totalWorkouts: Int,
        workoutsThisWeek: Int,
        workoutsThisMonth: Int,
        averageWorkoutsPerWeek: Double,
        currentStreak: Int,
        longestStreak: Int,
        lastWorkoutDate: Date?,
        daysSinceLastWorkout: Int?
    ) {
        self.totalWorkouts = totalWorkouts
        self.workoutsThisWeek = workoutsThisWeek
        self.workoutsThisMonth = workoutsThisMonth
        self.averageWorkoutsPerWeek = averageWorkoutsPerWeek
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastWorkoutDate = lastWorkoutDate
        self.daysSinceLastWorkout = daysSinceLastWorkout
    }
}
