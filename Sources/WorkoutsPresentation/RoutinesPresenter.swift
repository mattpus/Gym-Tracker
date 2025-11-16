import Foundation
import WorkoutsDomain

public final class RoutinesPresenter {
	private let routinesView: RoutinesView
	private let loadingView: RoutinesLoadingView
	private let errorView: RoutinesErrorView
	
	public init(
		routinesView: RoutinesView,
		loadingView: RoutinesLoadingView,
		errorView: RoutinesErrorView
	) {
		self.routinesView = routinesView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		"Routines"
	}
	
	public static var startButtonTitle: String {
		"Start Routine"
	}
	
	public func didStartLoadingRoutines() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishLoadingRoutines(with routines: [Routine]) {
		let cards = routines.map(makeCard)
		routinesView.display(.init(routines: cards))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishLoadingRoutines(with error: Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Error) -> String {
		"Could not load routines. Please try again."
	}
	
	private func makeCard(from routine: Routine) -> RoutineCardViewModel {
		let exerciseCount = routine.exercises.count
		let setCount = routine.exercises.flatMap(\.sets).count
		let detail = [
			formatted(exerciseCount, singular: "exercise", plural: "exercises"),
			formatted(setCount, singular: "set", plural: "sets")
		].joined(separator: " · ")
		
		return RoutineCardViewModel(
			id: routine.id,
			name: routine.name,
			detail: detail,
			startButtonTitle: Self.startButtonTitle
		)
	}
	
	private func formatted(_ count: Int, singular: String, plural: String) -> String {
		let unit = count == 1 ? singular : plural
		return "\(count) \(unit)"
	}
}
