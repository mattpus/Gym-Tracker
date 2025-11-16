import Foundation
import WorkoutsDomain

public struct WorkoutsViewModel: Equatable {
	public let workouts: [Workout]
	
	public init(workouts: [Workout]) {
		self.workouts = workouts
	}
}

public struct WorkoutsLoadingViewModel: Equatable {
	public let isLoading: Bool
	
	public init(isLoading: Bool) {
		self.isLoading = isLoading
	}
}

public struct WorkoutsErrorViewModel: Equatable {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
}
