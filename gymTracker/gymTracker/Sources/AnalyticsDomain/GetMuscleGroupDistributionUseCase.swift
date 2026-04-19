import Foundation

public protocol MuscleGroupDistributionCalculating {
    func calculate(days: Int) throws -> MuscleGroupDistribution
}

public final class GetMuscleGroupDistributionUseCase: MuscleGroupDistributionCalculating {
    private let repository: WorkoutDataRepository
    private let calendar: Calendar
    
    public init(repository: WorkoutDataRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func calculate(days: Int) throws -> MuscleGroupDistribution {
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())
        let workouts = try repository.loadWorkouts(from: startDate, to: Date())
        
        var muscleGroupSets: [String: Int] = [:]
        var totalSets = 0
        
        for workout in workouts {
            for exercise in workout.exercises {
                let setCount = exercise.sets.count
                totalSets += setCount
                
                if let muscleGroup = exercise.muscleGroup {
                    muscleGroupSets[muscleGroup, default: 0] += setCount
                }
            }
        }
        
        let distribution = muscleGroupSets.map { (muscle, sets) -> MuscleGroupPercentage in
            let percentage = totalSets > 0 ? (Double(sets) / Double(totalSets)) * 100 : 0
            return MuscleGroupPercentage(muscleGroup: muscle, setCount: sets, percentage: percentage)
        }.sorted { $0.setCount > $1.setCount }
        
        let mostTrained = distribution.first?.muscleGroup
        let leastTrained = distribution.last?.muscleGroup
        
        return MuscleGroupDistribution(
            distribution: distribution,
            mostTrainedMuscle: mostTrained,
            leastTrainedMuscle: leastTrained,
            totalSets: totalSets
        )
    }
}
