import Foundation

public struct ExercisePerformanceRecord: Equatable, Sendable {
    public let date: Date
    public let workoutId: UUID
    public let exerciseName: String
    public let setNumber: Int
    public let weight: Double?
    public let repetitions: Int?
    public let duration: TimeInterval?
    
    public init(
        date: Date,
        workoutId: UUID,
        exerciseName: String,
        setNumber: Int,
        weight: Double? = nil,
        repetitions: Int? = nil,
        duration: TimeInterval? = nil
    ) {
        self.date = date
        self.workoutId = workoutId
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.weight = weight
        self.repetitions = repetitions
        self.duration = duration
    }
    
    public var volume: Double? {
        guard let weight = weight, let reps = repetitions else { return nil }
        return weight * Double(reps)
    }
}
