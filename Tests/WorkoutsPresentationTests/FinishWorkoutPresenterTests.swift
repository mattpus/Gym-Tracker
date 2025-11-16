import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class FinishWorkoutPresenterTests: XCTestCase {
	
	func test_didStartFinishing_showsLoadingAndClearsError() {
		let (sut, view) = makeSUT()
		
		sut.didStartFinishing()
		
		XCTAssertEqual(view.loadingStates, [.init(isLoading: true)])
		XCTAssertEqual(view.errors, [.init(message: nil)])
	}
	
	func test_didFinish_displaysSummaryAndStopsLoading() {
		let (sut, view) = makeSUT()
		let summary = WorkoutSummary(
			workout: Workout(date: Date(), name: "Push", exercises: []),
			stats: WorkoutStats(totalSets: 2, totalVolume: 100, duration: 600)
		)
		
		sut.didFinish(with: summary)
		
		XCTAssertEqual(view.summaries, [.from(summary)])
		XCTAssertEqual(view.loadingStates.last, .init(isLoading: false))
	}
	
	func test_didFinishWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.didFinish(with: error)
		
		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
		XCTAssertEqual(view.loadingStates.last, .init(isLoading: false))
	}
	
	func test_discardFlow_notifiesView() {
		let (sut, view) = makeSUT()
		
		sut.requestDiscardConfirmation()
		XCTAssertEqual(view.discards.last, .init(shouldShowConfirmation: true, didDiscard: false))
		
		sut.didStartDiscarding()
		XCTAssertEqual(view.loadingStates.last, .init(isLoading: true))
		
		sut.didFinishDiscarding()
		XCTAssertEqual(view.discards.last, .init(shouldShowConfirmation: false, didDiscard: true))
		XCTAssertEqual(view.loadingStates.last, .init(isLoading: false))
		
		let error = NSError(domain: "test", code: 0)
		sut.didFailDiscarding(with: error)
		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
		XCTAssertEqual(view.loadingStates.last, .init(isLoading: false))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FinishWorkoutPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FinishWorkoutPresenter(summaryView: view, loadingView: view, errorView: view, discardView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private final class ViewSpy: FinishWorkoutSummaryView, FinishWorkoutLoadingView, FinishWorkoutErrorView, FinishWorkoutDiscardView {
		private(set) var summaries = [FinishWorkoutSummaryViewModel]()
		private(set) var loadingStates = [FinishWorkoutLoadingViewModel]()
		private(set) var errors = [FinishWorkoutErrorViewModel]()
		private(set) var discards = [FinishWorkoutDiscardViewModel]()
		
		func display(_ viewModel: FinishWorkoutSummaryViewModel) { summaries.append(viewModel) }
		func display(_ viewModel: FinishWorkoutLoadingViewModel) { loadingStates.append(viewModel) }
		func display(_ viewModel: FinishWorkoutErrorViewModel) { errors.append(viewModel) }
		func display(_ viewModel: FinishWorkoutDiscardViewModel) { discards.append(viewModel) }
	}
}
