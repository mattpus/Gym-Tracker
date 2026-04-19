import Foundation

/// Placeholder for future user profile system.
/// Will be used by advanced progression algorithms to personalize recommendations.
public struct UserProfile: Equatable, Sendable {
    public let id: UUID
    public let experienceLevel: ExperienceLevel
    public let primaryGoal: TrainingGoal
    public let recoveryCapacity: RecoveryCapacity
    
    public init(
        id: UUID = UUID(),
        experienceLevel: ExperienceLevel = .intermediate,
        primaryGoal: TrainingGoal = .strength,
        recoveryCapacity: RecoveryCapacity = .average
    ) {
        self.id = id
        self.experienceLevel = experienceLevel
        self.primaryGoal = primaryGoal
        self.recoveryCapacity = recoveryCapacity
    }
    
    public static var `default`: UserProfile {
        UserProfile()
    }
}

public enum ExperienceLevel: String, Equatable, Sendable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    case elite
    
    public var weeklyProgressionRate: Double {
        switch self {
        case .beginner: return 0.05      // 5% per week
        case .intermediate: return 0.025  // 2.5% per week
        case .advanced: return 0.01       // 1% per week
        case .elite: return 0.005         // 0.5% per week
        }
    }
}

public enum TrainingGoal: String, Equatable, Sendable, CaseIterable {
    case strength
    case hypertrophy
    case endurance
    case powerlifting
    case generalFitness
    
    public var targetRepRange: ClosedRange<Int> {
        switch self {
        case .strength: return 1...5
        case .hypertrophy: return 8...12
        case .endurance: return 15...20
        case .powerlifting: return 1...3
        case .generalFitness: return 8...15
        }
    }
}

public enum RecoveryCapacity: String, Equatable, Sendable, CaseIterable {
    case low
    case average
    case high
    
    public var suggestedRestDays: Int {
        switch self {
        case .low: return 3
        case .average: return 2
        case .high: return 1
        }
    }
}
