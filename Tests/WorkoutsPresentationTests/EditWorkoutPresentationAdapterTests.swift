import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

final class EditWorkoutPresentationAdapterTests: XCTestCase {
	
	func test_edit_requestsEditFromUseCase() {
		let editing = WorkoutEditingSpy()
		let sut = EditWorkoutPresentationAdapter(editing: editing)
		
		sut.edit(makeWorkout())
		
		XCTAssertEqual(editing.messages.count, 1)
	}
	
	func test_edit_notifiesPresenterLifecycleOnSuccess() {
		let editing = WorkoutEditingSpy()
		let sut = EditWorkoutPresentationAdapter(editing: editing)
		let view = CommandViewSpy()
		sut.presenter = WorkoutCommandPresenter(
			successMessage: "Saved",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let workout = makeWorkout()
		
		sut.edit(workout)
		editing.complete(with: .success(()))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.message("Saved"),
			.loading(false)
		])
	}
	
	func test_edit_notifiesPresenterOnError() {
		let editing = WorkoutEditingSpy()
		let sut = EditWorkoutPresentationAdapter(editing: editing)
		let view = CommandViewSpy()
		sut.presenter = WorkoutCommandPresenter(
			successMessage: "Saved",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let error = NSError(domain: "test", code: 0)
		
		sut.edit(makeWorkout())
		editing.complete(with: .failure(error))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.error("Something went wrong. Please try again."),
			.loading(false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeWorkout() -> Workout {
		Workout(date: Date(), name: "Test", exercises: [])
	}
	
	private final class WorkoutEditingSpy: WorkoutEditing {
		var messages = [(WorkoutEditing.Result) -> Void]()
		
		func edit(_ workout: Workout, completion: @escaping (WorkoutEditing.Result) -> Void) {
			messages.append(completion)
		}
		
		func complete(with result: WorkoutEditing.Result, at index: Int = 0) {
			messages[index](result)
		}
	}
	
	private final class CommandViewSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
		enum Event: Equatable {
			case message(String)
			case loading(Bool)
			case error(String?)
		}
		
		private(set) var events = [Event]()
		
		func display(_ viewModel: WorkoutCommandResultViewModel) {
			events.append(.message(viewModel.message))
		}
		
		func display(_ viewModel: WorkoutCommandLoadingViewModel) {
			events.append(.loading(viewModel.isLoading))
		}
		
		func display(_ viewModel: WorkoutsErrorViewModel) {
			events.append(.error(viewModel.message))
		}
	}
}
