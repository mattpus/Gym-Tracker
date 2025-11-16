import Foundation
import WorkoutsDomain

public struct FinishWorkoutSummaryViewModel: Equatable {
	public let workoutName: String
	public let totalSets: Int
	public let totalVolume: Double
	public let duration: TimeInterval
	
	public init(workoutName: String, totalSets: Int, totalVolume: Double, duration: TimeInterval) {
		self.workoutName = workoutName
		self.totalSets = totalSets
		self.totalVolume = totalVolume
		self.duration = duration
	}
	
	public static func from(_ summary: WorkoutSummary) -> FinishWorkoutSummaryViewModel {
		FinishWorkoutSummaryViewModel(
			workoutName: summary.workout.name,
			totalSets: summary.stats.totalSets,
			totalVolume: summary.stats.totalVolume,
			duration: summary.stats.duration
		)
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
