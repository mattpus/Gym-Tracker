import Foundation

public protocol WorkoutFrequencyCalculating {
    func calculate() throws -> WorkoutFrequencyInsight
}

public final class GetWorkoutFrequencyUseCase: WorkoutFrequencyCalculating {
    private let repository: WorkoutDataRepository
    private let calendar: Calendar
    
    public init(repository: WorkoutDataRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func calculate() throws -> WorkoutFrequencyInsight {
        let workouts = try repository.loadWorkouts(from: nil, to: nil)
        let now = Date()
        
        let sortedWorkouts = workouts.sorted { $0.date > $1.date }
        
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let workoutsThisWeek = workouts.filter { $0.date >= weekStart }.count
        let workoutsThisMonth = workouts.filter { $0.date >= monthStart }.count
        
        let averagePerWeek = calculateAveragePerWeek(workouts: workouts, now: now)
        let (currentStreak, longestStreak) = calculateStreaks(workouts: sortedWorkouts, now: now)
        
        let lastWorkoutDate = sortedWorkouts.first?.date
        let daysSinceLastWorkout = lastWorkoutDate.map { calendar.dateComponents([.day], from: $0, to: now).day ?? 0 }
        
        return WorkoutFrequencyInsight(
            totalWorkouts: workouts.count,
            workoutsThisWeek: workoutsThisWeek,
            workoutsThisMonth: workoutsThisMonth,
            averageWorkoutsPerWeek: averagePerWeek,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastWorkoutDate: lastWorkoutDate,
            daysSinceLastWorkout: daysSinceLastWorkout
        )
    }
    
    private func calculateAveragePerWeek(workouts: [WorkoutData], now: Date) -> Double {
        guard let firstWorkout = workouts.min(by: { $0.date < $1.date }) else { return 0 }
        
        let weeks = calendar.dateComponents([.weekOfYear], from: firstWorkout.date, to: now).weekOfYear ?? 1
        let totalWeeks = max(weeks, 1)
        
        return Double(workouts.count) / Double(totalWeeks)
    }
    
    private func calculateStreaks(workouts: [WorkoutData], now: Date) -> (current: Int, longest: Int) {
        guard !workouts.isEmpty else { return (0, 0) }
        
        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = workoutDays.sorted(by: >)
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var previousDay: Date?
        
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check if streak is active (workout today or yesterday)
        let streakActive = workoutDays.contains(today) || workoutDays.contains(yesterday)
        
        for day in sortedDays {
            if let prev = previousDay {
                let daysBetween = calendar.dateComponents([.day], from: day, to: prev).day ?? 0
                if daysBetween <= 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDay = day
        }
        
        longestStreak = max(longestStreak, tempStreak)
        currentStreak = streakActive ? tempStreak : 0
        
        return (currentStreak, longestStreak)
    }
}
