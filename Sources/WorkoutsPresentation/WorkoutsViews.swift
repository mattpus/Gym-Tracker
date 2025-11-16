import Foundation

public protocol WorkoutsView {
	func display(_ viewModel: WorkoutsViewModel)
}

public protocol WorkoutsLoadingView {
	func display(_ viewModel: WorkoutsLoadingViewModel)
}

public protocol WorkoutsErrorView {
	func display(_ viewModel: WorkoutsErrorViewModel)
}

public protocol WorkoutCommandView {
	func display(_ viewModel: WorkoutCommandResultViewModel)
}

public protocol WorkoutCommandLoadingView {
	func display(_ viewModel: WorkoutCommandLoadingViewModel)
}

public protocol ExerciseSetLoggingView {
	func display(_ viewModel: ExerciseSetLoggingViewModel)
}
