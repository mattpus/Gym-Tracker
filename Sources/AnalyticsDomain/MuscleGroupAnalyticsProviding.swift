import Foundation

public protocol MuscleGroupAnalyticsProviding {
    func getMuscleGroupDistribution(days: Int) throws -> MuscleGroupDistribution
    func getRecoveryStatus() throws -> RecoveryInsight
}
