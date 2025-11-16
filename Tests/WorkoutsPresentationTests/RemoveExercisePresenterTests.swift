import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RemoveExercisePresenterTests: XCTestCase {
	func test_confirmRemoval_showsConfirmation() {
		let (sut, view, _, _) = makeSUT()
		sut.confirmRemoval(workoutID: UUID(), exerciseID: UUID())
		XCTAssertEqual(view.confirmations.count, 1)
	}

	func test_remove_successUpdatesWorkout() {
		let workout = Workout(date: Date(), name: "Push", exercises: [])
		let (sut, view, remover, commandSpy) = makeSUT()
		var received: Workout?
		sut.onUpdatedWorkout = { received = $0 }

		sut.confirmRemoval(workoutID: UUID(), exerciseID: UUID())
		view.confirmations.last?.confirm()
		remover.complete(with: .success(workout))

		XCTAssertEqual(received, workout)
		XCTAssertEqual(commandSpy.loading, [.init(isLoading: true), .init(isLoading: false)])
	}

	func test_remove_failureShowsError() {
		let error = NSError(domain: "test", code: 0)
		let (sut, view, remover, commandSpy) = makeSUT()

		sut.confirmRemoval(workoutID: UUID(), exerciseID: UUID())
		view.confirmations.last?.confirm()
		remover.complete(with: .failure(error))

		XCTAssertEqual(commandSpy.errors.last?.message, "Something went wrong. Please try again.")
	}

	// MARK: - Helpers

	private func makeSUT() -> (RemoveExercisePresenter, ViewSpy, RemoverSpy, CommandSpy) {
		let view = ViewSpy()
		let remover = RemoverSpy()
		let commandSpy = CommandSpy()
		let commandPresenter = WorkoutCommandPresenter(successMessage: "Removed", commandView: commandSpy, loadingView: commandSpy, errorView: commandSpy)
		let sut = RemoveExercisePresenter(view: view, removing: remover, commandPresenter: commandPresenter)
		return (sut, view, remover, commandSpy)
	}

	private final class ViewSpy: RemoveExerciseView {
		private(set) var confirmations: [(message: String, confirm: () -> Void)] = []
		func displayConfirmation(message: String, confirm: @escaping () -> Void) { confirmations.append((message, confirm)) }
	}

	private final class RemoverSpy: WorkoutExerciseRemoving {
		private var completions = [(WorkoutExerciseRemoving.Result) -> Void]()
		func removeExercise(in workoutID: UUID, exerciseID: UUID, completion: @escaping (WorkoutExerciseRemoving.Result) -> Void) { completions.append(completion) }
		func complete(with result: WorkoutExerciseRemoving.Result, at index: Int = 0) { completions[index](result) }
	}

	private final class CommandSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		private(set) var commandMessages = [WorkoutCommandResultViewModel]()
		private(set) var loading = [WorkoutCommandLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()
		func display(_ viewModel: WorkoutCommandResultViewModel) { commandMessages.append(viewModel) }
		func display(_ viewModel: WorkoutCommandLoadingViewModel) { loading.append(viewModel) }
		func display(_ viewModel: WorkoutsErrorViewModel) { errors.append(viewModel) }
	}
}
