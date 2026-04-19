import Foundation

public struct WeightProgressionTrend: Equatable, Sendable {
    public let exerciseName: String
    public let dataPoints: [WeightDataPoint]
    public let startingWeight: Double?
    public let currentWeight: Double?
    public let maxWeight: Double?
    public let trend: Trend
    public let percentageChange: Double?
    
    public init(
        exerciseName: String,
        dataPoints: [WeightDataPoint],
        startingWeight: Double?,
        currentWeight: Double?,
        maxWeight: Double?,
        trend: Trend,
        percentageChange: Double?
    ) {
        self.exerciseName = exerciseName
        self.dataPoints = dataPoints
        self.startingWeight = startingWeight
        self.currentWeight = currentWeight
        self.maxWeight = maxWeight
        self.trend = trend
        self.percentageChange = percentageChange
    }
}

public struct WeightDataPoint: Equatable, Sendable {
    public let date: Date
    public let weight: Double
    public let reps: Int?
    
    public init(date: Date, weight: Double, reps: Int? = nil) {
        self.date = date
        self.weight = weight
        self.reps = reps
    }
}
