import Foundation

public struct FinishWorkoutSummaryViewModel: Equatable {
	public let workoutName: String
	public let totalSets: Int
	public let totalVolume: Double
	public let duration: TimeInterval
	public let formattedVolume: String
	public let formattedDuration: String

	public init(workoutName: String, totalSets: Int, totalVolume: Double, duration: TimeInterval, formattedVolume: String, formattedDuration: String) {
		self.workoutName = workoutName
		self.totalSets = totalSets
		self.totalVolume = totalVolume
		self.duration = duration
		self.formattedVolume = formattedVolume
		self.formattedDuration = formattedDuration
	}

	public static func from(_ summary: WorkoutSummary) -> FinishWorkoutSummaryViewModel {
		FinishWorkoutSummaryViewModel(
			workoutName: summary.workout.name,
			totalSets: summary.stats.totalSets,
			totalVolume: summary.stats.totalVolume,
			duration: summary.stats.duration,
			formattedVolume: Self.formatVolume(summary.stats.totalVolume),
			formattedDuration: Self.formatDuration(summary.stats.duration)
		)
	}

	private static func formatVolume(_ volume: Double) -> String {
		if volume.rounded() == volume {
			return "Total Volume: \(Int(volume))"
		}
		return String(format: "Total Volume: %.1f", volume)
	}

	private static func formatDuration(_ duration: TimeInterval) -> String {
		let totalSeconds = max(0, Int(duration))
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60
		if hours > 0 {
			return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
		}
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

public struct FinishWorkoutLoadingViewModel: Equatable {
	public let isLoading: Bool
	
	public init(isLoading: Bool) {
		self.isLoading = isLoading
	}
}

public struct FinishWorkoutErrorViewModel: Equatable {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
}

public struct FinishWorkoutDiscardViewModel: Equatable {
	public let shouldShowConfirmation: Bool
	public let didDiscard: Bool
	
	public init(shouldShowConfirmation: Bool, didDiscard: Bool) {
		self.shouldShowConfirmation = shouldShowConfirmation
		self.didDiscard = didDiscard
	}
}
