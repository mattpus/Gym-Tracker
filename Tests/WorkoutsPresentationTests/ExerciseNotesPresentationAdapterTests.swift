import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ExerciseNotesPresentationAdapterTests: XCTestCase {

	func test_updateNotes_requestsUseCase() {
		let (sut, updating, _, _) = makeSUT()
		let workoutID = UUID()
		let exerciseID = UUID()

		sut.updateNotes(in: workoutID, exerciseID: exerciseID, notes: "Test")

		XCTAssertEqual(updating.messages.count, 1)
		let message = updating.messages.first
		XCTAssertEqual(message?.workoutID, workoutID)
		XCTAssertEqual(message?.exerciseID, exerciseID)
		XCTAssertEqual(message?.notes, "Test")
	}

	func test_updateNotes_notifiesPresenterOnSuccess() {
		let (sut, updating, view, _) = makeSUT()
		let exerciseID = UUID()
		let workout = Workout(date: Date(), name: "Workout", exercises: [
			Exercise(id: exerciseID, name: "Bench", notes: "Updated", sets: [])
		])

		sut.updateNotes(in: workout.id, exerciseID: exerciseID, notes: "Updated")
		updating.complete(with: .success(workout))

		XCTAssertEqual(view.commandEvents, [.error(nil), .loading(true), .command("Notes saved"), .loading(false)])
		XCTAssertEqual(view.noteEvents, [.notes(exerciseID, "Updated", "Add note")])
	}

	func test_updateNotes_notifiesPresenterOnError() {
		let (sut, updating, view, _) = makeSUT()
		let error = NSError(domain: "test", code: 0)

		sut.updateNotes(in: UUID(), exerciseID: UUID(), notes: "Test")
		updating.complete(with: .failure(error))

		XCTAssertEqual(view.commandEvents.suffix(2), [.error("Something went wrong. Please try again."), .loading(false)])
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ExerciseNotesPresentationAdapter, updating: ExerciseNotesUpdatingSpy, view: ViewSpy, presenter: ExerciseNotesPresenter) {
		let updating = ExerciseNotesUpdatingSpy()
		let sut = ExerciseNotesPresentationAdapter(updating: updating)
		let view = ViewSpy()
		let presenter = makePresenter(view: view, file: file, line: line)
		sut.presenter = presenter
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(updating, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, updating, view, presenter)
	}

	private func makePresenter(view: ViewSpy, file: StaticString = #filePath, line: UInt = #line) -> ExerciseNotesPresenter {
		let commandPresenter = WorkoutCommandPresenter(
			successMessage: "Notes saved",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let presenter = ExerciseNotesPresenter(view: view, commandPresenter: commandPresenter, placeholder: "Add note")
		trackForMemoryLeaks(commandPresenter, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		return presenter
	}

	private final class ExerciseNotesUpdatingSpy: ExerciseNotesUpdating {
		struct Message {
			let workoutID: UUID
			let exerciseID: UUID
			let notes: String?
			let completion: (Result<Workout, Swift.Error>) -> Void
		}

		private(set) var messages = [Message]()

		func updateNotes(
			in workoutID: UUID,
			exerciseID: UUID,
			notes: String?,
			completion: @escaping (Result<Workout, Swift.Error>) -> Void
		) {
			messages.append(.init(workoutID: workoutID, exerciseID: exerciseID, notes: notes, completion: completion))
		}

		func complete(with result: Result<Workout, Swift.Error>, at index: Int = 0) {
			messages[index].completion(result)
		}
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
