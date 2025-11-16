import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

final class LoadWorkoutsPresentationAdapterTests: XCTestCase {
	
	func test_loadWorkouts_requestsWorkoutsFromLoader() {
		let loader = WorkoutsLoaderSpy()
		let sut = LoadWorkoutsPresentationAdapter(workoutsLoader: loader)
		
		sut.loadWorkouts()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	func test_loadWorkouts_notifiesPresenterOnSuccess() {
		let loader = WorkoutsLoaderSpy()
		let sut = LoadWorkoutsPresentationAdapter(workoutsLoader: loader)
		let view = ViewSpy()
		sut.presenter = WorkoutsPresenter(workoutsView: view, loadingView: view, errorView: view)
		let workouts = [Workout(date: Date(), name: "Push", exercises: [])]
		
		sut.loadWorkouts()
		loader.complete(with: .success(workouts))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.workouts(workouts),
			.loading(false)
		])
	}
	
	func test_loadWorkouts_deliversErrorsToPresenter() {
		let loader = WorkoutsLoaderSpy()
		let sut = LoadWorkoutsPresentationAdapter(workoutsLoader: loader)
		let view = ViewSpy()
		sut.presenter = WorkoutsPresenter(workoutsView: view, loadingView: view, errorView: view)
		let error = NSError(domain: "test", code: 0)
		
		sut.loadWorkouts()
		loader.complete(with: .failure(error))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.error("Could not load workouts. Please try again."),
			.loading(false)
		])
	}
	
	// MARK: - Helpers
	
	private final class WorkoutsLoaderSpy: WorkoutsLoading {
		private(set) var loadCallCount = 0
		private var completions = [(WorkoutsLoading.Result) -> Void]()
		
		func load(completion: @escaping (WorkoutsLoading.Result) -> Void) {
			loadCallCount += 1
			completions.append(completion)
		}
		
		func complete(with result: WorkoutsLoading.Result, at index: Int = 0) {
			completions[index](result)
		}
	}
	
	private final class ViewSpy: WorkoutsView, WorkoutsLoadingView, WorkoutsErrorView {
		enum Event: Equatable {
			case workouts([Workout])
			case loading(Bool)
			case error(String?)
		}
		
		private(set) var events = [Event]()
		
		func display(_ viewModel: WorkoutsViewModel) {
			events.append(.workouts(viewModel.workouts))
		}
		
		func display(_ viewModel: WorkoutsLoadingViewModel) {
			events.append(.loading(viewModel.isLoading))
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			events.append(.error(viewModel.message))
		}
	}
}
