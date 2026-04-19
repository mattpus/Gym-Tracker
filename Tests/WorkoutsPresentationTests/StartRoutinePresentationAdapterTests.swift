import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class StartRoutinePresentationAdapterTests: XCTestCase {
	
	func test_startRoutine_notifiesPresenterOnSuccess() {
		let (sut, useCase, views) = makeSUT()
		let workout = makeWorkout()
		
		sut.startRoutine(withID: UUID())
		useCase.complete(with: .success(workout))
		
		XCTAssertEqual(useCase.messages, [.start])
		XCTAssertEqual(views.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(views.commandMessages, [.init(message: "Started")])
		XCTAssertEqual(views.errors, [.init(message: nil)])
	}
	
	func test_startRoutine_notifiesPresenterOnFailure() {
		let (sut, useCase, views) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		let result = WorkoutScheduling.Result.failure(error)
		
		sut.startRoutine(withID: UUID())
		useCase.complete(with: result)
		
		XCTAssertEqual(views.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(views.commandMessages, [])
		XCTAssertEqual(views.errors, [
			.init(message: nil),
			.init(message: "Something went wrong. Please try again.")
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (StartRoutinePresentationAdapter, StartRoutineUseCaseSpy, ViewSpy) {
		let useCase = StartRoutineUseCaseSpy()
		let views = ViewSpy()
		let presenter = WorkoutCommandPresenter(
			successMessage: "Started",
			commandView: views,
			loadingView: views,
			errorView: views
		)
		let sut = StartRoutinePresentationAdapter(startRoutine: useCase)
		sut.presenter = presenter
		trackForMemoryLeaks(useCase, file: file, line: line)
		trackForMemoryLeaks(views, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, useCase, views)
	}

	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Started", exercises: [])
	}
	
	private final class StartRoutineUseCaseSpy: RoutineStarting {
		enum Message: Equatable {
			case start
		}
		
		private(set) var messages = [Message]()
		private var completions = [(WorkoutScheduling.Result) -> Void]()
		
		func startRoutine(id routineID: UUID, completion: @escaping (WorkoutScheduling.Result) -> Void) {
			messages.append(.start)
			completions.append(completion)
		}
		
		func complete(with result: WorkoutScheduling.Result, at index: Int = 0) {
			completions[index](result)
		}
	}
	
	private final class ViewSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		private(set) var commandMessages = [WorkoutCommandResultViewModel]()
		private(set) var loading = [WorkoutCommandLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()
		
		func display(_ viewModel: WorkoutCommandResultViewModel) {
			commandMessages.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutCommandLoadingViewModel) {
			loading.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			errors.append(viewModel)
		}
	}
}
