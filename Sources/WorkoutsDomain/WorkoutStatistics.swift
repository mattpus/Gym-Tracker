import Foundation

public struct WorkoutStatistics: Equatable, Sendable {
    public let workoutId: UUID
    public let workoutName: String
    public let date: Date
    public let duration: TimeInterval?
    public let exerciseCount: Int
    public let setCount: Int
    public let totalVolume: Double
    public let totalReps: Int
    
    public init(
        workoutId: UUID,
        workoutName: String,
        date: Date,
        duration: TimeInterval? = nil,
        exerciseCount: Int,
        setCount: Int,
        totalVolume: Double,
        totalReps: Int
    ) {
        self.workoutId = workoutId
        self.workoutName = workoutName
        self.date = date
        self.duration = duration
        self.exerciseCount = exerciseCount
        self.setCount = setCount
        self.totalVolume = totalVolume
        self.totalReps = totalReps
    }
}

extension WorkoutStatistics {
    public static func calculate(from workout: Workout, duration: TimeInterval? = nil) -> WorkoutStatistics {
        var totalVolume: Double = 0
        var totalReps = 0
        var setCount = 0
        
        for exercise in workout.exercises {
            for set in exercise.sets {
                setCount += 1
                if let reps = set.repetitions {
                    totalReps += reps
                    if let weight = set.weight {
                        totalVolume += weight * Double(reps)
                    }
                }
            }
        }
        
        return WorkoutStatistics(
            workoutId: workout.id,
            workoutName: workout.name,
            date: workout.date,
            duration: duration,
            exerciseCount: workout.exercises.count,
            setCount: setCount,
            totalVolume: totalVolume,
            totalReps: totalReps
        )
    }
}
