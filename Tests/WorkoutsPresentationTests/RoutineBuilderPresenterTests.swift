import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RoutineBuilderPresenterTests: XCTestCase {
	
	func test_start_displaysInitialState() {
		let (sut, view, _) = makeSUT()
		
		sut.start()
		
		XCTAssertEqual(view.displayed, [
			RoutineBuilderViewModel(title: "New Routine", name: "", isSaveEnabled: false, exercises: [])
		])
	}
	
	func test_didUpdateName_updatesViewModel() {
		let (sut, view, _) = makeSUT()
		
		sut.start()
		sut.didUpdateName("Push Day")
		
		XCTAssertEqual(view.displayed.last?.name, "Push Day")
	}
	
	func test_didSelectExercise_addsExerciseAndUpdatesView() {
		let (sut, view, _) = makeSUT()
		let item = ExerciseLibraryItem(id: UUID(), name: "Bench Press", primaryMuscle: "Chest")
		
		sut.start()
		sut.didSelectExercise(item)
		
		XCTAssertEqual(view.displayed.last?.exercises.first?.name, "Bench Press")
	}
	
	func test_didMoveExercise_reordersExercises() {
		let (sut, view, _) = makeSUT()
		let items = [
			ExerciseLibraryItem(id: UUID(), name: "Bench", primaryMuscle: nil),
			ExerciseLibraryItem(id: UUID(), name: "Deadlift", primaryMuscle: nil)
		]
		
		sut.start()
		items.forEach { sut.didSelectExercise($0) }
		sut.didMoveExercise(from: 0, to: 1)
		
		XCTAssertEqual(view.displayed.last?.exercises.map { $0.name }, ["Deadlift", "Bench"])
	}
	
	func test_didRequestSave_showsLoadingAndErrorsOnFailure() {
		let (sut, view, _) = makeSUT(saveResult: .failure(NSError(domain: "test", code: 0)))
		let item = ExerciseLibraryItem(id: UUID(), name: "Bench", primaryMuscle: nil)
		
		sut.start()
		sut.didUpdateName("Push")
		sut.didSelectExercise(item)
		sut.didRequestSave()
		
		XCTAssertEqual(view.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
	}
	
	func test_didSearchExercises_displaysSearchResults() {
		let (sut, view, searcher) = makeSUT()
		let item = ExerciseLibraryItem(id: UUID(), name: "Bench", primaryMuscle: "Chest")
		
		sut.didSearchExercises(query: "Bench")
		searcher.complete(with: .success([item]))
		
		XCTAssertEqual(view.searchResults.last?.items.first?.name, "Bench")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		saveResult: RoutineBuilding.Result = .success(()),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (RoutineBuilderPresenter, ViewSpy, ExerciseSearchSpy) {
		let view = ViewSpy()
		let create = RoutineBuildingSpy(result: saveResult)
		let reordering = RoutineReorderingUseCase()
		let searcher = ExerciseSearchSpy()
		let sut = RoutineBuilderPresenter(
			routineBuilderView: view,
			loadingView: view,
			errorView: view,
			searchResultsView: view,
			createRoutine: create,
			reordering: reordering,
			exerciseSearch: searcher
		)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(create, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view, searcher)
	}
	
	private final class ViewSpy: RoutineBuilderView, RoutineBuilderLoadingView, RoutineBuilderErrorView, RoutineSearchResultsView {
		private(set) var displayed = [RoutineBuilderViewModel]()
		private(set) var loading = [WorkoutCommandLoadingViewModel]()
		private(set) var errors = [WorkoutsErrorViewModel]()
		private(set) var searchResults = [RoutineSearchResultsViewModel]()
		
		func display(_ viewModel: RoutineBuilderViewModel) {
			displayed.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutCommandLoadingViewModel) {
			loading.append(viewModel)
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			errors.append(viewModel)
		}
		
		func display(_ viewModel: RoutineSearchResultsViewModel) {
			searchResults.append(viewModel)
		}
	}
	
	private final class RoutineBuildingSpy: RoutineBuilding {
		private let result: RoutineBuilding.Result
		
		init(result: RoutineBuilding.Result) {
			self.result = result
		}
		
		func create(_ routine: Routine, completion: @escaping (RoutineBuilding.Result) -> Void) {
			completion(result)
		}
	}
	
	private final class ExerciseSearchSpy: ExerciseLibrarySearching {
		private var completions = [(ExerciseLibrarySearching.Result) -> Void]()
		
		func search(query: String, completion: @escaping (ExerciseLibrarySearching.Result) -> Void) {
			completions.append(completion)
		}
		
		func complete(with result: ExerciseLibrarySearching.Result, at index: Int = 0) {
			completions[index](result)
		}
	}
}
