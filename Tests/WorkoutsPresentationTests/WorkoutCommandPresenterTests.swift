import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class WorkoutCommandPresenterTests: XCTestCase {
	
	func test_didStartCommand_displaysLoadingAndHidesError() {
		let (sut, view) = makeSUT()
		
		sut.didStartCommand()
		
		XCTAssertEqual(view.events, [
			.error(nil),
			.loading(true)
		])
	}
	
	func test_didFinishCommand_displaysSuccessAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishCommand()
		
		XCTAssertEqual(view.events, [
			.message("Done!"),
			.loading(false)
		])
	}
	
	func test_didFinishCommandWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.didFinishCommand(with: error)
		
		XCTAssertEqual(view.events, [
			.error("Something went wrong. Please try again."),
			.loading(false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: WorkoutCommandPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = WorkoutCommandPresenter(
			successMessage: "Done!",
			commandView: view,
			loadingView: view,
			errorView: view
		)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy: WorkoutCommandView, WorkoutCommandLoadingView, WorkoutsErrorView {
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
