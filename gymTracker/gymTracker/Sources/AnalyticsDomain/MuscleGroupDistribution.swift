import Foundation

public struct MuscleGroupDistribution: Equatable, Sendable {
    public let distribution: [MuscleGroupPercentage]
    public let mostTrainedMuscle: String?
    public let leastTrainedMuscle: String?
    public let totalSets: Int
    
    public init(
        distribution: [MuscleGroupPercentage],
        mostTrainedMuscle: String?,
        leastTrainedMuscle: String?,
        totalSets: Int
    ) {
        self.distribution = distribution
        self.mostTrainedMuscle = mostTrainedMuscle
        self.leastTrainedMuscle = leastTrainedMuscle
        self.totalSets = totalSets
    }
}

public struct MuscleGroupPercentage: Equatable, Sendable {
    public let muscleGroup: String
    public let setCount: Int
    public let percentage: Double
    
    public init(muscleGroup: String, setCount: Int, percentage: Double) {
        self.muscleGroup = muscleGroup
        self.setCount = setCount
        self.percentage = percentage
    }
}
