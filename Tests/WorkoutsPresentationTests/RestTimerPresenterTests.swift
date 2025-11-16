import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RestTimerPresenterTests: XCTestCase {
	
	func test_didUpdate_displaysTimerState() {
		let (sut, view) = makeSUT()
		let state = RestTimerState(exerciseID: UUID(), remaining: 15, isRunning: true)
		
		sut.didUpdate(state: state)
		
		XCTAssertEqual(view.timerViewModels, [
			RestTimerViewModel(exerciseID: state.exerciseID, remaining: 15, isRunning: true)
		])
	}
	
	func test_didUpdate_triggersAlertWhenRemainingReachesZero() {
		let (sut, view) = makeSUT()
		let state = RestTimerState(exerciseID: UUID(), remaining: 0, isRunning: false)
		
		sut.didUpdate(state: state)
		
		XCTAssertEqual(view.alertViewModels, [
			RestTimerAlertViewModel(exerciseID: state.exerciseID, shouldPlayAlert: true)
		])
	}
	
	func test_didUpdate_clearsAlertWhenTimerRunning() {
		let (sut, view) = makeSUT()
		let state = RestTimerState(exerciseID: UUID(), remaining: 5, isRunning: true)
		
		sut.didUpdate(state: state)
		
		XCTAssertEqual(view.alertViewModels.last, RestTimerAlertViewModel(exerciseID: state.exerciseID, shouldPlayAlert: false))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestTimerPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = RestTimerPresenter(restTimerView: view, alertView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy: RestTimerView, RestTimerAlertView {
		private(set) var timerViewModels = [RestTimerViewModel]()
		private(set) var alertViewModels = [RestTimerAlertViewModel]()
		
		func display(_ viewModel: RestTimerViewModel) {
			timerViewModels.append(viewModel)
		}
		
		func display(_ viewModel: RestTimerAlertViewModel) {
			alertViewModels.append(viewModel)
		}
	}
}
