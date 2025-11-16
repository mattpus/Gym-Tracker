import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RoutinesPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(RoutinesPresenter.title, "Routines")
	}
	
	func test_startButtonTitle_isLocalized() {
		XCTAssertEqual(RoutinesPresenter.startButtonTitle, "Start Routine")
	}
	
	func test_didStartLoadingRoutines_displaysLoadingAndHidesError() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingRoutines()
		
		XCTAssertEqual(view.loading, [.init(isLoading: true)])
		XCTAssertEqual(view.errors, [.init(message: nil)])
	}
	
	func test_didFinishLoadingRoutines_displaysMappedRoutinesAndStopsLoading() {
		let routine = makeRoutine(name: "Push", exerciseCount: 2, setCount: 5)
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingRoutines(with: [routine])
		
		XCTAssertEqual(view.routines.first?.routines, [
			RoutineCardViewModel(
				id: routine.id,
				name: "Push",
				detail: "2 exercises · 5 sets",
				startButtonTitle: "Start Routine"
			)
		])
		XCTAssertEqual(view.loading.last, .init(isLoading: false))
	}
	
	func test_didFinishLoadingRoutinesWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.didFinishLoadingRoutines(with: error)
		
		XCTAssertEqual(view.errors.last?.message, "Could not load routines. Please try again.")
		XCTAssertEqual(view.loading.last, .init(isLoading: false))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RoutinesPresenter, ViewSpy) {
		let view = ViewSpy()
		let sut = RoutinesPresenter(routinesView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeRoutine(name: String, exerciseCount: Int, setCount: Int) -> Routine {
		let sets = (0..<setCount).map { RoutineSet(order: $0) }
		var exercises = [RoutineExercise]()
		if exerciseCount > 0 {
			exercises.append(RoutineExercise(name: "Primary", sets: sets))
		}
		for index in 1..<exerciseCount {
			exercises.append(RoutineExercise(name: "Exercise \(index)", sets: []))
		}
		return Routine(name: name, exercises: exercises)
	}
	
	private final class ViewSpy: RoutinesView, RoutinesLoadingView, RoutinesErrorView {
		private(set) var routines = [RoutinesViewModel]()
		private(set) var loading = [RoutinesLoadingViewModel]()
		private(set) var errors = [RoutinesErrorViewModel]()
		
		func display(_ viewModel: RoutinesViewModel) {
			routines.append(viewModel)
		}
		
		func display(_ viewModel: RoutinesLoadingViewModel) {
			loading.append(viewModel)
		}
		
		func display(_ viewModel: RoutinesErrorViewModel) {
			errors.append(viewModel)
		}
	}
}
