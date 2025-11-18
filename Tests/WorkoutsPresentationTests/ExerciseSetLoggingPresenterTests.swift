import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ExerciseSetLoggingPresenterTests: XCTestCase {
	
	func test_didStartLogging_displaysLoadingAndClearsError() {
		let (sut, view) = makeSUT()
		
		sut.didStartLogging()
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true)
		])
	}
	
	func test_didFinishLogging_displaysResultAndStopsLoading() {
		let (sut, view) = makeSUT()
		let result = ExerciseSetLogResult(
			workout: makeWorkout(),
			exercise: makeExercise(),
			set: ExerciseSet(order: 0, repetitions: 10, weight: 100, duration: nil),
			previousSet: ExerciseSet(order: 0, repetitions: 8, weight: 95, duration: nil)
		)
		
		sut.didFinishLogging(with: result, action: .added)
		
		XCTAssertEqual(view.events.count, 2)
		if case let .logging(workout, exercise, set, previous, action, previousDisplay) = view.events.first {
			XCTAssertEqual(workout, result.workout)
			XCTAssertEqual(exercise, result.exercise)
			XCTAssertEqual(set, result.set)
			XCTAssertEqual(previous, result.previousSet)
			XCTAssertEqual(action, .added)
			XCTAssertEqual(previousDisplay, "95kg × 8")
		} else {
			XCTFail("Expected logging event")
		}
		XCTAssertEqual(view.events.last, .loading(false))
	}
	
	func test_didFinishDeleting_displaysDeletion() {
		let (sut, view) = makeSUT()
		let deletion = ExerciseSetDeletionResult(workout: makeWorkout(), exercise: makeExercise())
		
		sut.didFinishDeleting(with: deletion)
		
		XCTAssertEqual(view.events.count, 2)
		if case let .logging(workout, exercise, set, previous, action, previousDisplay) = view.events.first {
			XCTAssertEqual(workout, deletion.workout)
			XCTAssertEqual(exercise, deletion.exercise)
			XCTAssertNil(set)
			XCTAssertNil(previous)
			XCTAssertEqual(action, .deleted)
			XCTAssertEqual(previousDisplay, "-")
		} else {
			XCTFail("Expected logging event")
		}
		XCTAssertEqual(view.events.last, .loading(false))
	}
	
	func test_didFinishWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.didFinish(with: error)
		
		XCTAssertEqual(view.events, [
			.error("Something went wrong. Please try again."),
			.loading(false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ExerciseSetLoggingPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ExerciseSetLoggingPresenter(loggingView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Workout", exercises: [])
	}
	
	private func makeExercise() -> Exercise {
		Exercise(name: "Bench", notes: nil, sets: [])
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
