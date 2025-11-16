import Foundation
import WorkoutsDomain

public protocol ReplaceExerciseView: AnyObject {
	func display(_ viewModel: RoutineSearchResultsViewModel)
	func displayConfirmation(message: String, confirm: @escaping () -> Void)
}

public final class ReplaceExercisePresenter {
	private let view: ReplaceExerciseView
	private let searcher: ExerciseLibrarySearching
	private let replacing: WorkoutExerciseReplacing
	private let workoutID: UUID
	private let exerciseID: UUID
	private let commandPresenter: WorkoutCommandPresenter
	public var onUpdatedWorkout: ((Workout) -> Void)?

	public init(
		view: ReplaceExerciseView,
		searcher: ExerciseLibrarySearching,
		replacing: WorkoutExerciseReplacing,
		workoutID: UUID,
		exerciseID: UUID,
		commandPresenter: WorkoutCommandPresenter
	) {
		self.view = view
		self.searcher = searcher
		self.replacing = replacing
		self.workoutID = workoutID
		self.exerciseID = exerciseID
		self.commandPresenter = commandPresenter
	}

	public func search(query: String) {
		searcher.search(query: query) { [weak self] result in
			if case let .success(items) = result {
				self?.view.display(.init(items: items.map { RoutineSearchItemViewModel(id: $0.id, name: $0.name, subtitle: $0.primaryMuscle ?? "") }))
			}
		}
	}

	public func select(item: ExerciseLibraryItem) {
		let message = "Replacing this exercise will delete existing sets. Continue?"
		view.displayConfirmation(message: message) { [weak self] in self?.replace(with: item) }
	}

	private func replace(with item: ExerciseLibraryItem) {
		commandPresenter.didStartCommand()
		replacing.replaceExercise(in: workoutID, existingExerciseID: exerciseID, with: item) { [weak self] result in
			switch result {
			case let .success(workout):
				self?.onUpdatedWorkout?(workout)
				self?.commandPresenter.didFinishCommand()
			case let .failure(error):
				self?.commandPresenter.didFinishCommand(with: error)
			}
		}
	}
}
