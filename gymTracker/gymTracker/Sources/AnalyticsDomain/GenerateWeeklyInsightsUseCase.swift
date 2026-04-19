import Foundation

public protocol WeeklyInsightsGenerating {
    func generate() throws -> WeeklyInsightsSummary
}

public final class GenerateWeeklyInsightsUseCase: WeeklyInsightsGenerating {
    private let repository: WorkoutDataRepository
    private let calendar: Calendar
    
    public init(repository: WorkoutDataRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func generate() throws -> WeeklyInsightsSummary {
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: weekStart)!
        let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: weekStart)!
        
        let thisWeekWorkouts = try repository.loadWorkouts(from: weekStart, to: weekEnd)
        let lastWeekWorkouts = try repository.loadWorkouts(from: lastWeekStart, to: lastWeekEnd)
        
        let totalVolume = thisWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        let lastWeekVolume = lastWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        
        let totalDuration = thisWeekWorkouts.compactMap(\.duration).reduce(0, +)
        
        var exerciseCounts: [String: Int] = [:]
        var muscleGroupsHit = Set<String>()
        
        for workout in thisWeekWorkouts {
            for exercise in workout.exercises {
                exerciseCounts[exercise.name, default: 0] += 1
                if let muscle = exercise.muscleGroup {
                    muscleGroupsHit.insert(muscle)
                }
            }
        }
        
        let topExercises = exerciseCounts
            .map { ExerciseFrequency(exerciseName: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
        
        let volumeChange: Double? = lastWeekVolume > 0 ? ((totalVolume - lastWeekVolume) / lastWeekVolume) * 100 : nil
        let workoutChange = thisWeekWorkouts.count - lastWeekWorkouts.count
        
        return WeeklyInsightsSummary(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            workoutCount: thisWeekWorkouts.count,
            totalVolume: totalVolume,
            totalDuration: totalDuration > 0 ? totalDuration : nil,
            exercisesPerformed: exerciseCounts.count,
            topExercises: Array(topExercises),
            muscleGroupsHit: Array(muscleGroupsHit).sorted(),
            volumeChangeFromLastWeek: volumeChange,
            workoutChangeFromLastWeek: workoutChange
        )
    }
}
