import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class StartEmptyWorkoutPresentationAdapterTests: XCTestCase {
	
	func test_start_notifiesPresenterOnSuccess() {
		let (sut, starter, view) = makeSUT()
		let workout = makeWorkout()
		
		sut.start(name: nil)
		starter.complete(with: .success(workout))
		
		XCTAssertEqual(view.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(view.commandMessages, [.init(message: "Started")])
	}
	
	func test_start_notifiesPresenterOnFailure() {
		let (sut, starter, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		let result = WorkoutScheduling.Result.failure(error)
		
		sut.start(name: nil)
		starter.complete(with: result)
		
		XCTAssertEqual(view.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(view.commandMessages, [])
		XCTAssertEqual(view.errors, [
			.init(message: nil),
			.init(message: "Something went wrong. Please try again.")
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (StartEmptyWorkoutPresentationAdapter, StarterSpy, ViewSpy) {
		let starter = StarterSpy()
		let view = ViewSpy()
		let presenter = WorkoutCommandPresenter(
			successMessage: "Started",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let sut = StartEmptyWorkoutPresentationAdapter(starter: starter)
		sut.presenter = presenter
		trackForMemoryLeaks(starter, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, starter, view)
	}

	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Started", exercises: [])
	}
	
	private final class StarterSpy: EmptyWorkoutStarting {
		private var completions = [(WorkoutScheduling.Result) -> Void]()
		
		func startEmptyWorkout(named name: String?, completion: @escaping (WorkoutScheduling.Result) -> Void) {
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
