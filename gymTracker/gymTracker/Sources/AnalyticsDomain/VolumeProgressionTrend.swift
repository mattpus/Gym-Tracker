import Foundation

public struct VolumeProgressionTrend: Equatable, Sendable {
    public let dataPoints: [VolumeTrendDataPoint]
    public let totalVolume: Double
    public let averageVolumePerWorkout: Double
    public let trend: Trend
    public let percentageChange: Double?
    
    public init(
        dataPoints: [VolumeTrendDataPoint],
        totalVolume: Double,
        averageVolumePerWorkout: Double,
        trend: Trend,
        percentageChange: Double?
    ) {
        self.dataPoints = dataPoints
        self.totalVolume = totalVolume
        self.averageVolumePerWorkout = averageVolumePerWorkout
        self.trend = trend
        self.percentageChange = percentageChange
    }
}

public struct VolumeTrendDataPoint: Equatable, Sendable {
    public let date: Date
    public let volume: Double
    public let workoutName: String?
    
    public init(date: Date, volume: Double, workoutName: String? = nil) {
        self.date = date
        self.volume = volume
        self.workoutName = workoutName
    }
}

public enum Trend: String, Equatable, Sendable {
    case increasing
    case decreasing
    case stable
    case insufficient
}
