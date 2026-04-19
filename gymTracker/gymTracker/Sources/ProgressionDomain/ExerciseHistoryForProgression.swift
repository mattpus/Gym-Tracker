import Foundation

/// Historical data for an exercise used to calculate progression recommendations
public struct ExerciseHistoryForProgression: Equatable, Sendable {
    public let exerciseName: String
    public let recentSets: [HistoricalSet]
    public let personalRecord: PersonalRecord?
    
    public init(
        exerciseName: String,
        recentSets: [HistoricalSet],
        personalRecord: PersonalRecord?
    ) {
        self.exerciseName = exerciseName
        self.recentSets = recentSets
        self.personalRecord = personalRecord
    }
    
    public var lastSet: HistoricalSet? {
        recentSets.first
    }
    
    public var averageWeight: Double? {
        let weights = recentSets.compactMap(\.weight)
        guard !weights.isEmpty else { return nil }
        return weights.reduce(0, +) / Double(weights.count)
    }
    
    public var averageReps: Double? {
        let reps = recentSets.compactMap(\.reps)
        guard !reps.isEmpty else { return nil }
        return Double(reps.reduce(0, +)) / Double(reps.count)
    }
}

public struct HistoricalSet: Equatable, Sendable {
    public let date: Date
    public let weight: Double?
    public let reps: Int?
    public let wasCompleted: Bool
    
    public init(date: Date, weight: Double?, reps: Int?, wasCompleted: Bool = true) {
        self.date = date
        self.weight = weight
        self.reps = reps
        self.wasCompleted = wasCompleted
    }
    
    public var volume: Double? {
        guard let weight = weight, let reps = reps else { return nil }
        return weight * Double(reps)
    }
}

public struct PersonalRecord: Equatable, Sendable {
    public let maxWeight: Double
    public let maxWeightReps: Int?
    public let maxWeightDate: Date
    public let maxVolume: Double?
    public let maxVolumeDate: Date?
    
    public init(
        maxWeight: Double,
        maxWeightReps: Int?,
        maxWeightDate: Date,
        maxVolume: Double? = nil,
        maxVolumeDate: Date? = nil
    ) {
        self.maxWeight = maxWeight
        self.maxWeightReps = maxWeightReps
        self.maxWeightDate = maxWeightDate
        self.maxVolume = maxVolume
        self.maxVolumeDate = maxVolumeDate
    }
}
