import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ExerciseNotesPresenterTests: XCTestCase {

	func test_presentNotes_displaysViewModel() {
		let (sut, view) = makeSUT()
		let exercise = Exercise(id: UUID(), name: "Bench", notes: "Tight lats", sets: [])

		sut.presentNotes(for: exercise)

		XCTAssertEqual(view.noteEvents, [.notes(exercise.id, "Tight lats", "Add note")])
	}

	func test_didStartUpdatingNotes_displaysLoadingAndClearsError() {
		let (sut, view) = makeSUT()

		sut.didStartUpdatingNotes()

		XCTAssertEqual(view.commandEvents, [.error(nil), .loading(true)])
	}

	func test_didFinishUpdatingNotes_displaysUpdatedNotesAndStopsLoading() {
		let (sut, view) = makeSUT()
		let exercise = Exercise(id: UUID(), name: "Bench", notes: "New cues", sets: [])
		let workout = Workout(date: Date(), name: "Workout", exercises: [exercise])
		var receivedWorkout: Workout?
		sut.onUpdatedWorkout = { receivedWorkout = $0 }

		sut.didFinishUpdatingNotes(with: workout, exerciseID: exercise.id)

		XCTAssertEqual(receivedWorkout, workout)
		XCTAssertEqual(view.noteEvents, [.notes(exercise.id, "New cues", "Add note")])
		XCTAssertEqual(view.commandEvents.suffix(2), [.command("Notes saved"), .loading(false)])
	}

	func test_didFinishWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)

		sut.didFinish(with: error)

		XCTAssertEqual(view.commandEvents, [.error("Something went wrong. Please try again."), .loading(false)])
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ExerciseNotesPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let commandPresenter = WorkoutCommandPresenter(
			successMessage: "Notes saved",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let sut = ExerciseNotesPresenter(view: view, commandPresenter: commandPresenter, placeholder: "Add note")
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(commandPresenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}

	private final class ViewSpy: ExerciseNotesView, WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		enum CommandEvent: Equatable {
			case error(String?)
			case loading(Bool)
			case command(String)
		}

		enum NotesEvent: Equatable {
			case notes(UUID, String, String)
		}

		private(set) var commandEvents = [CommandEvent]()
		private(set) var noteEvents = [NotesEvent]()

		func display(_ viewModel: ExerciseNotesViewModel) {
			noteEvents.append(.notes(viewModel.exerciseID, viewModel.notes, viewModel.placeholder))
		}

		func display(_ viewModel: WorkoutCommandResultViewModel) {
			commandEvents.append(.command(viewModel.message))
		}

		func display(_ viewModel: WorkoutCommandLoadingViewModel) {
			commandEvents.append(.loading(viewModel.isLoading))
		}

		func display(_ viewModel: WorkoutsErrorViewModel) {
			commandEvents.append(.error(viewModel.message))
		}
	}
}
