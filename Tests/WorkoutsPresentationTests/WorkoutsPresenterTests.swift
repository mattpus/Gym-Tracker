import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class WorkoutsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(WorkoutsPresenter.title, "Workouts")
	}
	
	func test_didStartLoadingWorkouts_displaysLoadingIndicatorAndHidesError() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingWorkouts()
		
		XCTAssertEqual(view.loading, [.init(isLoading: true)])
		XCTAssertEqual(view.errors, [.init(message: nil)])
	}
	
	func test_didFinishLoadingWorkouts_displaysWorkoutsAndStopsLoading() {
		let workouts = [makeWorkout(name: "Push")]
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingWorkouts(with: workouts)
		
		XCTAssertEqual(view.workouts, [.init(workouts: workouts)])
		XCTAssertEqual(view.loading, [.init(isLoading: false)])
	}
	
	func test_didFinishLoadingWorkoutsWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.didFinishLoadingWorkouts(with: error)
		
		XCTAssertEqual(view.errors.last?.message, "Could not load workouts. Please try again.")
		XCTAssertEqual(view.loading.last, .init(isLoading: false))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: WorkoutsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = WorkoutsPresenter(workoutsView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeWorkout(name: String) -> Workout {
		Workout(date: Date(), name: name, exercises: [])
	}
	
	private final class ViewSpy: WorkoutsView, WorkoutsLoadingView, WorkoutsErrorView {
		private(set) var workouts = [WorkoutsViewModel]()
		private(set) var loading = [WorkoutsLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()
		
		func display(_ viewModel: WorkoutsViewModel) {
			workouts.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutsLoadingViewModel) {
			loading.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			errors.append(viewModel)
		}
	}
}
