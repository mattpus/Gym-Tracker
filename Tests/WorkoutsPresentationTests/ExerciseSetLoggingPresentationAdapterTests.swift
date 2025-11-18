import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ExerciseSetLoggingPresentationAdapterTests: XCTestCase {
	
	func test_addSet_requestsLoggingAndNotifiesPresenter() {
		let useCase = ExerciseSetLoggingSpy()
		let restTimer = RestTimerHandlerSpy()
		let (sut, view) = makeSUT(logging: useCase, restTimerHandler: restTimer)
		let workoutID = UUID()
		let exerciseID = UUID()
		let request = ExerciseSetRequest(repetitions: 8, weight: 60, duration: nil)
		let result = ExerciseSetLogResult(
			workout: makeWorkout(id: workoutID),
			exercise: makeExercise(id: exerciseID),
			set: ExerciseSet(order: 0),
			previousSet: nil
		)
		
		let exp = expectation(description: "Wait for rest timer")
		restTimer.onHandle = {
			exp.fulfill()
		}
		
		sut.addSet(to: workoutID, exerciseID: exerciseID, request: request)
		useCase.completeAdd(with: .success(result))
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(useCase.addMessages.count, 1)
		XCTAssertEqual(view.events.count, 4)
		XCTAssertEqual(view.events[0], .error(nil))
		XCTAssertEqual(view.events[1], .loading(true))
		if case let .logging(workout, exercise, set, previous, action, previousDisplay) = view.events[2] {
			XCTAssertEqual(workout, result.workout)
			XCTAssertEqual(exercise, result.exercise)
			XCTAssertEqual(set, result.set)
			XCTAssertEqual(previous, result.previousSet)
			XCTAssertEqual(action, .added)
			XCTAssertEqual(previousDisplay, "-")
		} else {
			XCTFail("Expected logging event")
		}
		XCTAssertEqual(view.events[3], .loading(false))
		XCTAssertEqual(restTimer.handledExerciseIDs, [exerciseID])
	}
	
	func test_updateSet_notifiesPresenterOnError() {
		let useCase = ExerciseSetLoggingSpy()
		let (sut, view) = makeSUT(logging: useCase)
		let error = anyError()
		
		sut.updateSet(in: UUID(), exerciseID: UUID(), setID: UUID(), request: ExerciseSetRequest(repetitions: 5, weight: 50, duration: nil))
		useCase.completeUpdate(with: .failure(error))
		
		XCTAssertTrue(view.events.contains(.error("Something went wrong. Please try again.")))
		XCTAssertEqual(view.events.last, .loading(false))
	}
	
	func test_deleteSet_notifiesPresenterOnSuccess() {
		let useCase = ExerciseSetLoggingSpy()
		let (sut, view) = makeSUT(logging: useCase)
		let deletion = ExerciseSetDeletionResult(workout: makeWorkout(), exercise: makeExercise())
		
		sut.deleteSet(in: UUID(), exerciseID: UUID(), setID: UUID())
		useCase.completeDelete(with: .success(deletion))
		
		let suffix = view.events.suffix(2)
		if case let .logging(workout, exercise, set, previous, action, previousDisplay) = suffix.first {
			XCTAssertEqual(workout, deletion.workout)
			XCTAssertEqual(exercise, deletion.exercise)
			XCTAssertNil(set)
			XCTAssertNil(previous)
			XCTAssertEqual(action, .deleted)
			XCTAssertEqual(previousDisplay, "-")
		} else {
			XCTFail("Expected logging event")
		}
		XCTAssertEqual(suffix.last, .loading(false))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(logging: ExerciseSetLoggingSpy, restTimerHandler: RestTimerHandling? = nil, file: StaticString = #filePath, line: UInt = #line) -> (sut: ExerciseSetLoggingPresentationAdapter, view: ViewSpy) {
		let sut = ExerciseSetLoggingPresentationAdapter(logging: logging, restTimerHandler: restTimerHandler)
		let view = ViewSpy()
		let presenter = ExerciseSetLoggingPresenter(loggingView: view, loadingView: view, errorView: view)
		sut.presenter = presenter
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeWorkout(id: UUID = UUID()) -> Workout {
		Workout(id: id, date: Date(), name: "Workout", exercises: [])
	}
	
	private func makeExercise(id: UUID = UUID()) -> Exercise {
		Exercise(id: id, name: "Bench", sets: [])
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
	
	private final class ExerciseSetLoggingSpy: ExerciseSetLogging {
		var addMessages = [(UUID, UUID, ExerciseSetRequest, LogCompletion)]()
		var updateMessages = [(UUID, UUID, UUID, ExerciseSetRequest, LogCompletion)]()
		var deleteMessages = [(UUID, UUID, UUID, DeleteCompletion)]()
		
		func addSet(to workoutID: UUID, exerciseID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion) {
			addMessages.append((workoutID, exerciseID, request, completion))
		}
		
		func updateSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, request: ExerciseSetRequest, completion: @escaping LogCompletion) {
			updateMessages.append((workoutID, exerciseID, setID, request, completion))
		}
		
		func deleteSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, completion: @escaping DeleteCompletion) {
			deleteMessages.append((workoutID, exerciseID, setID, completion))
		}
		
		func completeAdd(with result: Result<ExerciseSetLogResult, Error>, at index: Int = 0) {
			addMessages[index].3(result)
		}
		
		func completeUpdate(with result: Result<ExerciseSetLogResult, Error>, at index: Int = 0) {
			updateMessages[index].4(result)
		}
		
		func completeDelete(with result: Result<ExerciseSetDeletionResult, Error>, at index: Int = 0) {
			deleteMessages[index].3(result)
		}
	}
	
	private final class ViewSpy: ExerciseSetLoggingView, WorkoutCommandLoadingView, WorkoutsErrorView {
		enum Event: Equatable {
			case logging(Workout, Exercise, ExerciseSet?, ExerciseSet?, ExerciseSetLoggingViewModel.Action, String)
			case loading(Bool)
			case error(String?)
		}

		private(set) var events = [Event]()

		func display(_ viewModel: ExerciseSetLoggingViewModel) {
			events.append(.logging(viewModel.workout, viewModel.exercise, viewModel.set, viewModel.previousSet, viewModel.action, viewModel.previousDisplay))
		}
		
		func display(_ viewModel: WorkoutCommandLoadingViewModel) {
			events.append(.loading(viewModel.isLoading))
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			events.append(.error(viewModel.message))
		}
	}
}
private final class RestTimerHandlerSpy: RestTimerHandling {
	private(set) var handledExerciseIDs = [UUID]()
	var onHandle: (() -> Void)?
	
	func handleSetCompletion(for exerciseID: UUID) async {
		handledExerciseIDs.append(exerciseID)
		onHandle?()
	}
}
