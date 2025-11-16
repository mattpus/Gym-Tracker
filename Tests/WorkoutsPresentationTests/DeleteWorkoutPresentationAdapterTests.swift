import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

final class DeleteWorkoutPresentationAdapterTests: XCTestCase {
	
	func test_delete_requestsDeleteFromUseCase() {
		let deleting = WorkoutDeletingSpy()
		let sut = DeleteWorkoutPresentationAdapter(deleting: deleting)
		
		sut.delete(workoutID: UUID())
		
		XCTAssertEqual(deleting.messages.count, 1)
	}
	
	func test_delete_notifiesPresenterOnSuccess() {
		let deleting = WorkoutDeletingSpy()
		let sut = DeleteWorkoutPresentationAdapter(deleting: deleting)
		let view = CommandViewSpy()
		sut.presenter = WorkoutCommandPresenter(
			successMessage: "Deleted",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		
		sut.delete(workoutID: UUID())
		deleting.complete(with: .success(()))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.message("Deleted"),
			.loading(false)
		])
	}
	
	func test_delete_notifiesPresenterOnFailure() {
		let deleting = WorkoutDeletingSpy()
		let sut = DeleteWorkoutPresentationAdapter(deleting: deleting)
		let view = CommandViewSpy()
		sut.presenter = WorkoutCommandPresenter(
			successMessage: "Deleted",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		let error = NSError(domain: "test", code: 0)
		
		sut.delete(workoutID: UUID())
		deleting.complete(with: .failure(error))
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true),
			.error("Something went wrong. Please try again."),
			.loading(false)
		])
	}
	
	// MARK: - Helpers
	
	private final class WorkoutDeletingSpy: WorkoutDeleting {
		var messages = [(WorkoutDeleting.Result) -> Void]()
		
		func delete(workoutID: UUID, completion: @escaping (WorkoutDeleting.Result) -> Void) {
			messages.append(completion)
		}
		
		func complete(with result: WorkoutDeleting.Result, at index: Int = 0) {
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
