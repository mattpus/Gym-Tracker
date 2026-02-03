import Foundation
import AnalyticsDomain

/// ViewModel for the Analytics Dashboard
@Observable
@MainActor
final class AnalyticsDashboardViewModel {
    var workoutFrequency: WorkoutFrequencyData?
    var muscleDistribution: [MuscleGroupData] = []
    var weeklyInsights: WeeklyInsightsData?
    var isLoading = false
    var error: Error?
    
    private let workoutFrequencyUseCase: WorkoutFrequencyCalculating
    private let muscleDistributionUseCase: MuscleGroupDistributionCalculating
    private let weeklyInsightsUseCase: WeeklyInsightsGenerating
    
    init(
        workoutFrequencyUseCase: WorkoutFrequencyCalculating,
        muscleDistributionUseCase: MuscleGroupDistributionCalculating,
        weeklyInsightsUseCase: WeeklyInsightsGenerating
    ) {
        self.workoutFrequencyUseCase = workoutFrequencyUseCase
        self.muscleDistributionUseCase = muscleDistributionUseCase
        self.weeklyInsightsUseCase = weeklyInsightsUseCase
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        do {
            let frequencyInsight = try workoutFrequencyUseCase.calculate()
            workoutFrequency = WorkoutFrequencyData(
                currentStreak: frequencyInsight.currentStreak,
                longestStreak: frequencyInsight.longestStreak,
                workoutsThisWeek: frequencyInsight.workoutsThisWeek,
                workoutsThisMonth: frequencyInsight.workoutsThisMonth,
                totalWorkouts: frequencyInsight.totalWorkouts
            )
            
            let distribution = try muscleDistributionUseCase.calculate(days: 30)
            muscleDistribution = distribution.distribution.map {
                MuscleGroupData(name: $0.muscleGroup, percentage: $0.percentage, setCount: $0.setCount)
            }
            
            let insights = try weeklyInsightsUseCase.generate()
            weeklyInsights = WeeklyInsightsData(
                totalVolume: insights.totalVolume,
                volumeChange: insights.volumeChangeFromLastWeek ?? 0,
                workoutCount: insights.workoutCount,
                averageDuration: insights.totalDuration ?? 0
            )
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct WorkoutFrequencyData {
    let currentStreak: Int
    let longestStreak: Int
    let workoutsThisWeek: Int
    let workoutsThisMonth: Int
    let totalWorkouts: Int
}

struct MuscleGroupData: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let setCount: Int
}

struct WeeklyInsightsData {
    let totalVolume: Double
    let volumeChange: Double
    let workoutCount: Int
    let averageDuration: TimeInterval
}

/// ViewModel for Workout Frequency detail
@Observable
@MainActor
final class WorkoutFrequencyViewModel {
    var data: WorkoutFrequencyData?
    var isLoading = false
    
    private let workoutFrequencyUseCase: WorkoutFrequencyCalculating
    
    init(workoutFrequencyUseCase: WorkoutFrequencyCalculating) {
        self.workoutFrequencyUseCase = workoutFrequencyUseCase
    }
    
    func loadData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let insight = try workoutFrequencyUseCase.calculate()
            data = WorkoutFrequencyData(
                currentStreak: insight.currentStreak,
                longestStreak: insight.longestStreak,
                workoutsThisWeek: insight.workoutsThisWeek,
                workoutsThisMonth: insight.workoutsThisMonth,
                totalWorkouts: insight.totalWorkouts
            )
        } catch {
            // Handle error
        }
    }
}

/// ViewModel for Muscle Distribution detail
@Observable
@MainActor
final class MuscleDistributionViewModel {
    var groups: [MuscleGroupData] = []
    var isLoading = false
    
    private let muscleDistributionUseCase: MuscleGroupDistributionCalculating
    
    init(muscleDistributionUseCase: MuscleGroupDistributionCalculating) {
        self.muscleDistributionUseCase = muscleDistributionUseCase
    }
    
    func loadData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let distribution = try muscleDistributionUseCase.calculate(days: 30)
            groups = distribution.distribution.map {
                MuscleGroupData(name: $0.muscleGroup, percentage: $0.percentage, setCount: $0.setCount)
            }
        } catch {
            // Handle error
        }
    }
}

/// ViewModel for Weight Progression detail
@Observable
@MainActor
final class WeightProgressionViewModel {
    var dataPoints: [AppWeightDataPoint] = []
    var trend: String = ""
    var isLoading = false
    
    private let exerciseName: String
    private let weightProgressionUseCase: WeightProgressionCalculating
    
    init(exerciseName: String, weightProgressionUseCase: WeightProgressionCalculating) {
        self.exerciseName = exerciseName
        self.weightProgressionUseCase = weightProgressionUseCase
    }
    
    func loadData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let progression = try weightProgressionUseCase.calculate(for: exerciseName, days: 30)
            dataPoints = progression.dataPoints.map {
                AppWeightDataPoint(date: $0.date, weight: $0.weight)
            }
            trend = progression.trend.rawValue
        } catch {
            // Handle error
        }
    }
}

struct AppWeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

/// ViewModel for Volume Progression detail
@Observable
@MainActor
final class VolumeProgressionViewModel {
    var dataPoints: [VolumeDataPoint] = []
    var isLoading = false
    
    private let volumeProgressionUseCase: VolumeProgressionCalculating
    
    init(volumeProgressionUseCase: VolumeProgressionCalculating) {
        self.volumeProgressionUseCase = volumeProgressionUseCase
    }
    
    func loadData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let progression = try volumeProgressionUseCase.calculate(days: 30)
            dataPoints = progression.dataPoints.map {
                VolumeDataPoint(date: $0.date, volume: $0.volume)
            }
        } catch {
            // Handle error
        }
    }
}

struct VolumeDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let volume: Double
}

/// ViewModel for Recovery detail
@Observable
@MainActor
final class RecoveryViewModel {
    var muscleGroupRecovery: [MuscleRecoveryData] = []
    var isLoading = false
    
    private let recoveryStatusUseCase: RecoveryStatusCalculating
    
    init(recoveryStatusUseCase: RecoveryStatusCalculating) {
        self.recoveryStatusUseCase = recoveryStatusUseCase
    }
    
    func loadData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let recovery = try recoveryStatusUseCase.calculate()
            muscleGroupRecovery = recovery.muscleGroupRecovery.map {
                MuscleRecoveryData(
                    name: $0.muscleGroup,
                    recoveryPercentage: recoveryPercentage(for: $0.recoveryStatus),
                    lastTrained: $0.lastTrainedDate
                )
            }
        } catch {
            // Handle error
        }
    }
    
    private func recoveryPercentage(for status: RecoveryLevel) -> Double {
        switch status {
        case .fullyRecovered: return 100.0
        case .mostlyRecovered: return 75.0
        case .recovering: return 50.0
        case .recentlyTrained: return 25.0
        case .neverTrained: return 100.0
        }
    }
}

struct MuscleRecoveryData: Identifiable {
    let id = UUID()
    let name: String
    let recoveryPercentage: Double
    let lastTrained: Date?
}
