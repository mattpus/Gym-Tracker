import Foundation

public final class LocalMuscleGroupAnalyticsProvider: MuscleGroupAnalyticsProviding {
    private let distributionUseCase: MuscleGroupDistributionCalculating
    private let recoveryUseCase: RecoveryStatusCalculating
    
    public init(
        distributionUseCase: MuscleGroupDistributionCalculating,
        recoveryUseCase: RecoveryStatusCalculating
    ) {
        self.distributionUseCase = distributionUseCase
        self.recoveryUseCase = recoveryUseCase
    }
    
    public func getMuscleGroupDistribution(days: Int) throws -> MuscleGroupDistribution {
        try distributionUseCase.calculate(days: days)
    }
    
    public func getRecoveryStatus() throws -> RecoveryInsight {
        try recoveryUseCase.calculate()
    }
}
