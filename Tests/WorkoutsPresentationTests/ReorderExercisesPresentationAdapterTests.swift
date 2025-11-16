import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ReorderExercisesPresentationAdapterTests: XCTestCase {
	func test_reorder_notifiesPresenterOnSuccess() {
		let (sut, spy, view) = makeSUT()
		let workout = Workout(date: Date(), name: "Push", exercises: [])

		sut.reorder(workoutID: workout.id, from: 0, to: 1)
		spy.complete(with: .success(workout))

		XCTAssertEqual(view.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(view.commandMessages, [.init(message: "Updated")])
	}

	func test_reorder_deliversErrorToPresenter() {
		let (sut, spy, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)

		sut.reorder(workoutID: UUID(), from: 0, to: 1)
		spy.complete(with: .failure(error))

		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
	}

	func test_reorder_forwardsUpdatedWorkout() {
		let (sut, spy, _) = makeSUT()
		let workout = Workout(date: Date(), name: "Push", exercises: [])
		var receivedWorkout: Workout?
		sut.onReordered = { receivedWorkout = $0 }

		sut.reorder(workoutID: workout.id, from: 0, to: 1)
		spy.complete(with: .success(workout))

		XCTAssertEqual(receivedWorkout, workout)
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (ReorderExercisesPresentationAdapter, ReorderSpy, ViewSpy) {
		let spy = ReorderSpy()
		let view = ViewSpy()
		let presenter = WorkoutCommandPresenter(
			successMessage: "Updated",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let sut = ReorderExercisesPresentationAdapter(reordering: spy)
		sut.presenter = presenter
		trackForMemoryLeaks(spy, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, spy, view)
	}

	private final class ReorderSpy: WorkoutExerciseReordering {
		private var completions = [(WorkoutExerciseReordering.Result) -> Void]()
		func reorderExercises(in workoutID: UUID, from sourceIndex: Int, to destinationIndex: Int, completion: @escaping (WorkoutExerciseReordering.Result) -> Void) {
			completions.append(completion)
		}
		func complete(with result: WorkoutExerciseReordering.Result, at index: Int = 0) {
			completions[index](result)
		}
	}

	private final class ViewSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		private(set) var commandMessages = [WorkoutCommandResultViewModel]()
		private(set) var loading = [WorkoutCommandLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()

		func display(_ viewModel: WorkoutCommandResultViewModel) { commandMessages.append(viewModel) }
		func display(_ viewModel: WorkoutCommandLoadingViewModel) { loading.append(viewModel) }
		func display(_ viewModel: WorkoutsErrorViewModel) { errors.append(viewModel) }
	}
}
