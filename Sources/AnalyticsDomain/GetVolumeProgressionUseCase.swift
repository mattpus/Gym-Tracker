import Foundation

public protocol VolumeProgressionCalculating {
    func calculate(days: Int) throws -> VolumeProgressionTrend
}

public final class GetVolumeProgressionUseCase: VolumeProgressionCalculating {
    private let repository: WorkoutDataRepository
    private let calendar: Calendar
    
    public init(repository: WorkoutDataRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func calculate(days: Int) throws -> VolumeProgressionTrend {
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())
        let workouts = try repository.loadWorkouts(from: startDate, to: Date())
        
        let sortedWorkouts = workouts.sorted { $0.date < $1.date }
        
        let dataPoints = sortedWorkouts.map { workout in
            VolumeDataPoint(date: workout.date, volume: workout.totalVolume, workoutName: workout.name)
        }
        
        let totalVolume = workouts.reduce(0) { $0 + $1.totalVolume }
        let averageVolume = workouts.isEmpty ? 0 : totalVolume / Double(workouts.count)
        
        let (trend, percentageChange) = calculateTrend(dataPoints: dataPoints)
        
        return VolumeProgressionTrend(
            dataPoints: dataPoints,
            totalVolume: totalVolume,
            averageVolumePerWorkout: averageVolume,
            trend: trend,
            percentageChange: percentageChange
        )
    }
    
    private func calculateTrend(dataPoints: [VolumeDataPoint]) -> (Trend, Double?) {
        guard dataPoints.count >= 2 else {
            return (.insufficient, nil)
        }
        
        let halfIndex = dataPoints.count / 2
        let firstHalf = Array(dataPoints.prefix(halfIndex))
        let secondHalf = Array(dataPoints.suffix(from: halfIndex))
        
        let firstAverage = firstHalf.reduce(0) { $0 + $1.volume } / Double(max(firstHalf.count, 1))
        let secondAverage = secondHalf.reduce(0) { $0 + $1.volume } / Double(max(secondHalf.count, 1))
        
        guard firstAverage > 0 else {
            return (.insufficient, nil)
        }
        
        let percentageChange = ((secondAverage - firstAverage) / firstAverage) * 100
        
        let trend: Trend
        if percentageChange > 5 {
            trend = .increasing
        } else if percentageChange < -5 {
            trend = .decreasing
        } else {
            trend = .stable
        }
        
        return (trend, percentageChange)
    }
}
