import Foundation

public struct WeeklyInsightsSummary: Equatable, Sendable {
    public let weekStartDate: Date
    public let weekEndDate: Date
    public let workoutCount: Int
    public let totalVolume: Double
    public let totalDuration: TimeInterval?
    public let exercisesPerformed: Int
    public let topExercises: [ExerciseFrequency]
    public let muscleGroupsHit: [String]
    public let volumeChangeFromLastWeek: Double?
    public let workoutChangeFromLastWeek: Int?
    
    public init(
        weekStartDate: Date,
        weekEndDate: Date,
        workoutCount: Int,
        totalVolume: Double,
        totalDuration: TimeInterval?,
        exercisesPerformed: Int,
        topExercises: [ExerciseFrequency],
        muscleGroupsHit: [String],
        volumeChangeFromLastWeek: Double?,
        workoutChangeFromLastWeek: Int?
    ) {
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.workoutCount = workoutCount
        self.totalVolume = totalVolume
        self.totalDuration = totalDuration
        self.exercisesPerformed = exercisesPerformed
        self.topExercises = topExercises
        self.muscleGroupsHit = muscleGroupsHit
        self.volumeChangeFromLastWeek = volumeChangeFromLastWeek
        self.workoutChangeFromLastWeek = workoutChangeFromLastWeek
    }
}

public struct ExerciseFrequency: Equatable, Sendable {
    public let exerciseName: String
    public let count: Int
    
    public init(exerciseName: String, count: Int) {
        self.exerciseName = exerciseName
        self.count = count
    }
}
