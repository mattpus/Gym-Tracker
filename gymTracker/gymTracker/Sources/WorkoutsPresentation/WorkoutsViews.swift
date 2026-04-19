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

public protocol ExerciseNotesView {
	func display(_ viewModel: ExerciseNotesViewModel)
}

public protocol ExerciseActionMenuView {
	func display(_ viewModel: ExerciseActionMenuViewModel)
}

public protocol RestTimerView {
	func display(_ viewModel: RestTimerViewModel)
}

public protocol RestTimerAlertView {
	func display(_ viewModel: RestTimerAlertViewModel)
}

public protocol FinishWorkoutSummaryView {
	func display(_ viewModel: FinishWorkoutSummaryViewModel)
}

public protocol FinishWorkoutLoadingView {
	func display(_ viewModel: FinishWorkoutLoadingViewModel)
}

public protocol FinishWorkoutErrorView {
	func display(_ viewModel: FinishWorkoutErrorViewModel)
}

public protocol FinishWorkoutDiscardView {
	func display(_ viewModel: FinishWorkoutDiscardViewModel)
}

public protocol RoutinesView {
	func display(_ viewModel: RoutinesViewModel)
}

public protocol RoutinesLoadingView {
	func display(_ viewModel: RoutinesLoadingViewModel)
}

public protocol RoutinesErrorView {
	func display(_ viewModel: RoutinesErrorViewModel)
}

public protocol RoutineBuilderDisplaying {
	func display(_ viewModel: RoutineBuilderScreenViewModel)
}

public protocol RoutineBuilderLoadingView {
	func display(_ viewModel: WorkoutCommandLoadingViewModel)
}

public protocol RoutineBuilderErrorView {
	func display(_ viewModel: WorkoutsErrorViewModel)
}

public protocol RoutineSearchResultsView {
	func display(_ viewModel: RoutineSearchResultsViewModel)
}
