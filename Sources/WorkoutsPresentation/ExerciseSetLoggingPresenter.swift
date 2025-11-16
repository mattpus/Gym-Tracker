import Foundation
import WorkoutsDomain

public final class ExerciseSetLoggingPresenter {
	private let loggingView: ExerciseSetLoggingView
	private let loadingView: WorkoutCommandLoadingView
	private let errorView: WorkoutsErrorView
	
	public init(
		loggingView: ExerciseSetLoggingView,
		loadingView: WorkoutCommandLoadingView,
		errorView: WorkoutsErrorView
	) {
		self.loggingView = loggingView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLogging() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishLogging(with result: ExerciseSetLogResult, action: ExerciseSetLoggingViewModel.Action) {
		let viewModel = ExerciseSetLoggingViewModel(
			workout: result.workout,
			exercise: result.exercise,
			set: result.set,
			previousSet: result.previousSet,
			action: action
		)
		loggingView.display(viewModel)
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishDeleting(with result: ExerciseSetDeletionResult) {
		let viewModel = ExerciseSetLoggingViewModel(
			workout: result.workout,
			exercise: result.exercise,
			set: nil,
			previousSet: nil,
			action: .deleted
		)
		loggingView.display(viewModel)
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinish(with error: Swift.Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Swift.Error) -> String {
		"Something went wrong. Please try again."
	}
}
