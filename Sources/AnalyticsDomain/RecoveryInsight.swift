import Foundation

public struct RecoveryInsight: Equatable, Sendable {
    public let muscleGroupRecovery: [MuscleRecoveryStatus]
    public let fullyRecoveredMuscles: [String]
    public let recoveringMuscles: [String]
    
    public init(
        muscleGroupRecovery: [MuscleRecoveryStatus],
        fullyRecoveredMuscles: [String],
        recoveringMuscles: [String]
    ) {
        self.muscleGroupRecovery = muscleGroupRecovery
        self.fullyRecoveredMuscles = fullyRecoveredMuscles
        self.recoveringMuscles = recoveringMuscles
    }
}

public struct MuscleRecoveryStatus: Equatable, Sendable {
    public let muscleGroup: String
    public let lastTrainedDate: Date?
    public let daysSinceTraining: Int?
    public let recoveryStatus: RecoveryLevel
    public let suggestedRestDays: Int
    
    public init(
        muscleGroup: String,
        lastTrainedDate: Date?,
        daysSinceTraining: Int?,
        recoveryStatus: RecoveryLevel,
        suggestedRestDays: Int = 2
    ) {
        self.muscleGroup = muscleGroup
        self.lastTrainedDate = lastTrainedDate
        self.daysSinceTraining = daysSinceTraining
        self.recoveryStatus = recoveryStatus
        self.suggestedRestDays = suggestedRestDays
    }
}

public enum RecoveryLevel: String, Equatable, Sendable {
    case fullyRecovered
    case mostlyRecovered
    case recovering
    case recentlyTrained
    case neverTrained
    
    public static func fromDaysSinceTraining(_ days: Int?) -> RecoveryLevel {
        guard let days else { return .neverTrained }
        switch days {
        case 0: return .recentlyTrained
        case 1: return .recovering
        case 2: return .mostlyRecovered
        default: return .fullyRecovered
        }
    }
}
