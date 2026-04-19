import Foundation

public protocol WeightProgressionCalculating {
    func calculate(for exerciseName: String, days: Int) throws -> WeightProgressionTrend
}

public final class GetWeightProgressionUseCase: WeightProgressionCalculating {
    private let repository: WorkoutDataRepository
    private let calendar: Calendar
    
    public init(repository: WorkoutDataRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func calculate(for exerciseName: String, days: Int) throws -> WeightProgressionTrend {
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())
        let workouts = try repository.loadWorkouts(from: startDate, to: Date())
        
        var dataPoints: [WeightDataPoint] = []
        
        for workout in workouts.sorted(by: { $0.date < $1.date }) {
            for exercise in workout.exercises {
                guard exercise.name.lowercased() == exerciseName.lowercased() else { continue }
                
                // Get the heaviest set for this exercise in this workout
                if let heaviestSet = exercise.sets.compactMap({ set -> (weight: Double, reps: Int?)? in
                    guard let weight = set.weight else { return nil }
                    return (weight, set.reps)
                }).max(by: { $0.weight < $1.weight }) {
                    dataPoints.append(WeightDataPoint(
                        date: workout.date,
                        weight: heaviestSet.weight,
                        reps: heaviestSet.reps
                    ))
                }
            }
        }
        
        let startingWeight = dataPoints.first?.weight
        let currentWeight = dataPoints.last?.weight
        let maxWeight = dataPoints.map(\.weight).max()
        
        let (trend, percentageChange) = calculateTrend(dataPoints: dataPoints)
        
        return WeightProgressionTrend(
            exerciseName: exerciseName,
            dataPoints: dataPoints,
            startingWeight: startingWeight,
            currentWeight: currentWeight,
            maxWeight: maxWeight,
            trend: trend,
            percentageChange: percentageChange
        )
    }
    
    private func calculateTrend(dataPoints: [WeightDataPoint]) -> (Trend, Double?) {
        guard dataPoints.count >= 2,
              let first = dataPoints.first?.weight,
              let last = dataPoints.last?.weight,
              first > 0 else {
            return (.insufficient, nil)
        }
        
        let percentageChange = ((last - first) / first) * 100
        
        let trend: Trend
        if percentageChange > 2 {
            trend = .increasing
        } else if percentageChange < -2 {
            trend = .decreasing
        } else {
            trend = .stable
        }
        
        return (trend, percentageChange)
    }
}
