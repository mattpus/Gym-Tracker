import Foundation
import ProgressionDomain

/// Configuration for future advanced progression algorithms.
/// This is a placeholder that will be expanded when implementing smart progression.
public struct ProgressionAlgorithmConfig: Equatable, Codable, Sendable {
    public let weightIncrementKg: Double
    public let weightIncrementLbs: Double
    public let minRepsForProgression: Int
    public let maxRepsBeforeWeightIncrease: Int
    public let deloadPercentage: Double
    public let deloadFrequencyWeeks: Int
    
    public init(
        weightIncrementKg: Double = 2.5,
        weightIncrementLbs: Double = 5.0,
        minRepsForProgression: Int = 6,
        maxRepsBeforeWeightIncrease: Int = 12,
        deloadPercentage: Double = 0.1,
        deloadFrequencyWeeks: Int = 4
    ) {
        self.weightIncrementKg = weightIncrementKg
        self.weightIncrementLbs = weightIncrementLbs
        self.minRepsForProgression = minRepsForProgression
        self.maxRepsBeforeWeightIncrease = maxRepsBeforeWeightIncrease
        self.deloadPercentage = deloadPercentage
        self.deloadFrequencyWeeks = deloadFrequencyWeeks
    }
    
    public static var `default`: ProgressionAlgorithmConfig {
        ProgressionAlgorithmConfig()
    }
    
    // Presets for different training styles
    public static var strength: ProgressionAlgorithmConfig {
        ProgressionAlgorithmConfig(
            weightIncrementKg: 2.5,
            minRepsForProgression: 3,
            maxRepsBeforeWeightIncrease: 5,
            deloadPercentage: 0.1,
            deloadFrequencyWeeks: 4
        )
    }
    
    public static var hypertrophy: ProgressionAlgorithmConfig {
        ProgressionAlgorithmConfig(
            weightIncrementKg: 2.5,
            minRepsForProgression: 8,
            maxRepsBeforeWeightIncrease: 12,
            deloadPercentage: 0.15,
            deloadFrequencyWeeks: 6
        )
    }
    
    public static var endurance: ProgressionAlgorithmConfig {
        ProgressionAlgorithmConfig(
            weightIncrementKg: 1.25,
            minRepsForProgression: 15,
            maxRepsBeforeWeightIncrease: 20,
            deloadPercentage: 0.1,
            deloadFrequencyWeeks: 8
        )
    }
}
