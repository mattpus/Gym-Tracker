import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class SaveWorkoutAsRoutinePresentationAdapterTests: XCTestCase {
	
	func test_save_notifiesPresenterOnSuccess() {
		let (sut, saver, view) = makeSUT()
		
		sut.save(workout: makeWorkout(), as: nil)
		saver.complete(with: .success(()))
		
		XCTAssertEqual(view.loading, [.init(isLoading: true), .init(isLoading: false)])
		XCTAssertEqual(view.commandMessages, [.init(message: "Saved")])
	}
	
	func test_save_notifiesPresenterOnFailure() {
		let (sut, saver, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.save(workout: makeWorkout(), as: nil)
		saver.complete(with: .failure(error))
		
		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (SaveWorkoutAsRoutinePresentationAdapter, WorkoutRoutineSavingSpy, ViewSpy) {
		let saver = WorkoutRoutineSavingSpy()
		let view = ViewSpy()
		let presenter = WorkoutCommandPresenter(
			successMessage: "Saved",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let sut = SaveWorkoutAsRoutinePresentationAdapter(saver: saver)
		sut.presenter = presenter
		trackForMemoryLeaks(saver, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, saver, view)
	}
	
	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Push", exercises: [])
	}
	
	private final class WorkoutRoutineSavingSpy: WorkoutRoutineSaving {
		private var completions = [(WorkoutRoutineSaving.Result) -> Void]()
		
		func save(workout: Workout, as routineName: String?, completion: @escaping (WorkoutRoutineSaving.Result) -> Void) {
			completions.append(completion)
		}
		
		func complete(with result: WorkoutRoutineSaving.Result, at index: Int = 0) {
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
