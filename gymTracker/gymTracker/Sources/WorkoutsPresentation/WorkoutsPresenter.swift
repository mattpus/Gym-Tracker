import Foundation

public final class WorkoutsPresenter {
	private let workoutsView: WorkoutsView
	private let loadingView: WorkoutsLoadingView
	private let errorView: WorkoutsErrorView
	
	public static var title: String {
		"Workouts"
	}
	
	public init(
		workoutsView: WorkoutsView,
		loadingView: WorkoutsLoadingView,
		errorView: WorkoutsErrorView
	) {
		self.workoutsView = workoutsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingWorkouts() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishLoadingWorkouts(with workouts: [Workout]) {
		workoutsView.display(.init(workouts: workouts))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishLoadingWorkouts(with error: Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Error) -> String {
		NSError(domain: "WorkoutsPresenter.Error", code: 0, userInfo: [
			NSLocalizedDescriptionKey: "Could not load workouts. Please try again."
		]).localizedDescription
	}
}
