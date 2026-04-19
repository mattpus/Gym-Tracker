import Foundation

public protocol RecoveryStatusCalculating {
    func calculate() throws -> RecoveryInsight
}

public final class GetRecoveryStatusUseCase: RecoveryStatusCalculating {
    private let repository: WorkoutDataRepository
    private let muscleGroups: [String]
    private let calendar: Calendar
    
    public init(
        repository: WorkoutDataRepository,
        muscleGroups: [String] = ["chest", "back", "shoulders", "biceps", "triceps", "quadriceps", "hamstrings", "glutes", "calves", "core"],
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.muscleGroups = muscleGroups
        self.calendar = calendar
    }
    
    public func calculate() throws -> RecoveryInsight {
        let startDate = calendar.date(byAdding: .day, value: -14, to: Date())
        let workouts = try repository.loadWorkouts(from: startDate, to: Date())
        
        var lastTrainedDates: [String: Date] = [:]
        
        for workout in workouts {
            for exercise in workout.exercises {
                guard let muscleGroup = exercise.muscleGroup?.lowercased() else { continue }
                
                if let existing = lastTrainedDates[muscleGroup] {
                    if workout.date > existing {
                        lastTrainedDates[muscleGroup] = workout.date
                    }
                } else {
                    lastTrainedDates[muscleGroup] = workout.date
                }
            }
        }
        
        let now = Date()
        var recoveryStatuses: [MuscleRecoveryStatus] = []
        var fullyRecovered: [String] = []
        var recovering: [String] = []
        
        for muscle in muscleGroups {
            let lastTrained = lastTrainedDates[muscle]
            let daysSince = lastTrained.map { calendar.dateComponents([.day], from: $0, to: now).day ?? 0 }
            let status = RecoveryLevel.fromDaysSinceTraining(daysSince)
            
            let recoveryStatus = MuscleRecoveryStatus(
                muscleGroup: muscle,
                lastTrainedDate: lastTrained,
                daysSinceTraining: daysSince,
                recoveryStatus: status
            )
            recoveryStatuses.append(recoveryStatus)
            
            switch status {
            case .fullyRecovered, .neverTrained:
                fullyRecovered.append(muscle)
            case .recentlyTrained, .recovering, .mostlyRecovered:
                recovering.append(muscle)
            }
        }
        
        return RecoveryInsight(
            muscleGroupRecovery: recoveryStatuses,
            fullyRecoveredMuscles: fullyRecovered,
            recoveringMuscles: recovering
        )
    }
}
