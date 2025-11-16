import Foundation
import WorkoutsDomain

public final class FinishWorkoutPresenter {
	private let summaryView: FinishWorkoutSummaryView
	private let loadingView: FinishWorkoutLoadingView
	private let errorView: FinishWorkoutErrorView
	private let discardView: FinishWorkoutDiscardView
	
	public init(
		summaryView: FinishWorkoutSummaryView,
		loadingView: FinishWorkoutLoadingView,
		errorView: FinishWorkoutErrorView,
		discardView: FinishWorkoutDiscardView
	) {
		self.summaryView = summaryView
		self.loadingView = loadingView
		self.errorView = errorView
		self.discardView = discardView
	}
	
	public func didStartFinishing() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinish(with summary: WorkoutSummary) {
		summaryView.display(.from(summary))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinish(with error: Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	public func requestDiscardConfirmation() {
		discardView.display(.init(shouldShowConfirmation: true, didDiscard: false))
	}
	
	public func didStartDiscarding() {
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishDiscarding() {
		discardView.display(.init(shouldShowConfirmation: false, didDiscard: true))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFailDiscarding(with error: Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Error) -> String {
		"Something went wrong. Please try again."
	}
}
