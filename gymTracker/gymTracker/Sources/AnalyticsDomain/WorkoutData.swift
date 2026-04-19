import Foundation

public struct WorkoutData: Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let name: String
    public let totalVolume: Double
    public let duration: TimeInterval?
    public let exercises: [ExerciseData]
    
    public init(
        id: UUID,
        date: Date,
        name: String,
        totalVolume: Double,
        duration: TimeInterval? = nil,
        exercises: [ExerciseData]
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.totalVolume = totalVolume
        self.duration = duration
        self.exercises = exercises
    }
}

public struct ExerciseData: Equatable, Sendable {
    public let name: String
    public let muscleGroup: String?
    public let sets: [SetData]
    
    public init(name: String, muscleGroup: String?, sets: [SetData]) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.sets = sets
    }
}

public struct SetData: Equatable, Sendable {
    public let weight: Double?
    public let reps: Int?
    
    public init(weight: Double?, reps: Int?) {
        self.weight = weight
        self.reps = reps
    }
}
