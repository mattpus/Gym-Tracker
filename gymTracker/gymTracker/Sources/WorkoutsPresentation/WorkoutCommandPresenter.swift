import Foundation

public final class WorkoutCommandPresenter {
	private let commandView: WorkoutCommandView
	private let loadingView: WorkoutCommandLoadingView
	private let errorView: WorkoutsErrorView
	private let successMessage: String
	
	public init(
		successMessage: String,
		commandView: WorkoutCommandView,
		loadingView: WorkoutCommandLoadingView,
		errorView: WorkoutsErrorView
	) {
		self.successMessage = successMessage
		self.commandView = commandView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartCommand() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishCommand() {
		commandView.display(.init(message: successMessage))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishCommand(with error: Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Error) -> String {
		"Something went wrong. Please try again."
	}
}
