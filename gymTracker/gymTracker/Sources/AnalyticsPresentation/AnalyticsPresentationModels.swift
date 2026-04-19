import Foundation

public struct AnalyticsWorkoutFrequencyViewModel: Equatable {
    public let totalWorkouts: String
    public let workoutsThisWeek: String
    public let workoutsThisMonth: String
    public let averagePerWeek: String
    public let currentStreak: String
    public let longestStreak: String
    public let lastWorkoutText: String
    
    public init(
        totalWorkouts: String,
        workoutsThisWeek: String,
        workoutsThisMonth: String,
        averagePerWeek: String,
        currentStreak: String,
        longestStreak: String,
        lastWorkoutText: String
    ) {
        self.totalWorkouts = totalWorkouts
        self.workoutsThisWeek = workoutsThisWeek
        self.workoutsThisMonth = workoutsThisMonth
        self.averagePerWeek = averagePerWeek
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastWorkoutText = lastWorkoutText
    }
}

public struct AnalyticsMuscleDistributionViewModel: Equatable {
    public let items: [MuscleDistributionItem]
    public let mostTrained: String?
    public let leastTrained: String?
    
    public init(items: [MuscleDistributionItem], mostTrained: String?, leastTrained: String?) {
        self.items = items
        self.mostTrained = mostTrained
        self.leastTrained = leastTrained
    }
}

public struct MuscleDistributionItem: Equatable {
    public let muscleGroup: String
    public let percentage: String
    public let setCount: String
    public let barWidth: Double
    
    public init(muscleGroup: String, percentage: String, setCount: String, barWidth: Double) {
        self.muscleGroup = muscleGroup
        self.percentage = percentage
        self.setCount = setCount
        self.barWidth = barWidth
    }
}

public struct AnalyticsVolumeProgressionViewModel: Equatable {
    public let dataPoints: [VolumeChartPoint]
    public let totalVolumeText: String
    public let averageVolumeText: String
    public let trendText: String
    public let trendDirection: TrendDirection
    
    public init(
        dataPoints: [VolumeChartPoint],
        totalVolumeText: String,
        averageVolumeText: String,
        trendText: String,
        trendDirection: TrendDirection
    ) {
        self.dataPoints = dataPoints
        self.totalVolumeText = totalVolumeText
        self.averageVolumeText = averageVolumeText
        self.trendText = trendText
        self.trendDirection = trendDirection
    }
}

public struct VolumeChartPoint: Equatable {
    public let dateLabel: String
    public let volume: Double
    public let volumeText: String
    
    public init(dateLabel: String, volume: Double, volumeText: String) {
        self.dateLabel = dateLabel
        self.volume = volume
        self.volumeText = volumeText
    }
}

public struct AnalyticsWeightProgressionViewModel: Equatable {
    public let exerciseName: String
    public let dataPoints: [WeightChartPoint]
    public let startingWeightText: String?
    public let currentWeightText: String?
    public let maxWeightText: String?
    public let trendText: String
    public let trendDirection: TrendDirection
    
    public init(
        exerciseName: String,
        dataPoints: [WeightChartPoint],
        startingWeightText: String?,
        currentWeightText: String?,
        maxWeightText: String?,
        trendText: String,
        trendDirection: TrendDirection
    ) {
        self.exerciseName = exerciseName
        self.dataPoints = dataPoints
        self.startingWeightText = startingWeightText
        self.currentWeightText = currentWeightText
        self.maxWeightText = maxWeightText
        self.trendText = trendText
        self.trendDirection = trendDirection
    }
}

public struct WeightChartPoint: Equatable {
    public let dateLabel: String
    public let weight: Double
    public let weightText: String
    public let repsText: String?
    
    public init(dateLabel: String, weight: Double, weightText: String, repsText: String?) {
        self.dateLabel = dateLabel
        self.weight = weight
        self.weightText = weightText
        self.repsText = repsText
    }
}

public struct AnalyticsRecoveryViewModel: Equatable {
    public let muscleStatuses: [MuscleAnalyticsRecoveryViewModel]
    public let readyToTrainText: String
    public let needsRestText: String
    
    public init(muscleStatuses: [MuscleAnalyticsRecoveryViewModel], readyToTrainText: String, needsRestText: String) {
        self.muscleStatuses = muscleStatuses
        self.readyToTrainText = readyToTrainText
        self.needsRestText = needsRestText
    }
}

public struct MuscleAnalyticsRecoveryViewModel: Equatable {
    public let muscleGroup: String
    public let statusText: String
    public let statusColor: RecoveryColor
    public let lastTrainedText: String?
    
    public init(muscleGroup: String, statusText: String, statusColor: RecoveryColor, lastTrainedText: String?) {
        self.muscleGroup = muscleGroup
        self.statusText = statusText
        self.statusColor = statusColor
        self.lastTrainedText = lastTrainedText
    }
}

public enum TrendDirection: String, Equatable {
    case up
    case down
    case stable
    case unknown
}

public enum RecoveryColor: String, Equatable {
    case green
    case yellow
    case orange
    case red
    case gray
}
