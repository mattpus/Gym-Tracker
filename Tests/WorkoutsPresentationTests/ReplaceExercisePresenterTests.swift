import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ReplaceExercisePresenterTests: XCTestCase {
	func test_search_displaysResults() {
		let (sut, view, searcher, _, _) = makeSUT()
		let item = ExerciseLibraryItem(id: UUID(), name: "Row", primaryMuscle: "Back")

		sut.search(query: "row")
		searcher.complete(with: .success([item]))

		XCTAssertEqual(view.results.last?.items.first?.name, "Row")
	}

	func test_select_asksForConfirmation() {
		let (sut, view, _, _, _) = makeSUT()
		let item = ExerciseLibraryItem(id: UUID(), name: "Row", primaryMuscle: nil)

		sut.select(item: item)

		XCTAssertEqual(view.confirmations.count, 1)
	}

	func test_replace_triggersCommandPresenter() {
		let (sut, view, _, replacer, presenterSpy) = makeSUT()
		sut.select(item: ExerciseLibraryItem(id: UUID(), name: "Row", primaryMuscle: nil))
		view.confirmations.last?.confirm()
		replacer.complete(with: .success(makeWorkout()))

		XCTAssertEqual(presenterSpy.loading, [.init(isLoading: true), .init(isLoading: false)])
	}

	// MARK: - Helpers

	private func makeSUT() -> (ReplaceExercisePresenter, ViewSpy, SearcherSpy, ReplacerSpy, CommandPresenterSpy) {
		let view = ViewSpy()
		let searcher = SearcherSpy()
		let replacer = ReplacerSpy()
		let commandView = CommandPresenterSpy()
		let presenter = WorkoutCommandPresenter(successMessage: "Replaced", commandView: commandView, loadingView: commandView, errorView: commandView)
		let sut = ReplaceExercisePresenter(
			view: view,
			searcher: searcher,
			replacing: replacer,
			workoutID: UUID(),
			exerciseID: UUID(),
			commandPresenter: presenter
		)
		return (sut, view, searcher, replacer, commandView)
	}

	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Push", exercises: [])
	}

	private final class ViewSpy: ReplaceExerciseView {
		private(set) var results = [RoutineSearchResultsViewModel]()
		private(set) var confirmations: [(message: String, confirm: () -> Void)] = []
		func display(_ viewModel: RoutineSearchResultsViewModel) { results.append(viewModel) }
		func displayConfirmation(message: String, confirm: @escaping () -> Void) { confirmations.append((message, confirm)) }
	}

	private final class SearcherSpy: ExerciseLibrarySearching {
		private var completions = [(ExerciseLibrarySearching.Result) -> Void]()
		func search(query: String, completion: @escaping (ExerciseLibrarySearching.Result) -> Void) { completions.append(completion) }
		func complete(with result: ExerciseLibrarySearching.Result, at index: Int = 0) { completions[index](result) }
	}

	private final class ReplacerSpy: WorkoutExerciseReplacing {
		private var completions = [(WorkoutExerciseReplacing.Result) -> Void]()
		func replaceExercise(in workoutID: UUID, existingExerciseID: UUID, with newExercise: ExerciseLibraryItem, completion: @escaping (WorkoutExerciseReplacing.Result) -> Void) { completions.append(completion) }
		func complete(with result: WorkoutExerciseReplacing.Result, at index: Int = 0) { completions[index](result) }
	}

	private final class CommandPresenterSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		private(set) var commandMessages = [WorkoutCommandResultViewModel]()
		private(set) var loading = [WorkoutCommandLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()
		func display(_ viewModel: WorkoutCommandResultViewModel) { commandMessages.append(viewModel) }
		func display(_ viewModel: WorkoutCommandLoadingViewModel) { loading.append(viewModel) }
		func display(_ viewModel: WorkoutsErrorViewModel) { errors.append(viewModel) }
	}
}
