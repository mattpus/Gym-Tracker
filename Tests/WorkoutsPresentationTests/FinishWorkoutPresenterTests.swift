import XCTest
@testable import WorkoutsPresentation

@MainActor
final class FinishWorkoutPresenterTests: XCTestCase {

	func test_didSaveRoutine_displaysCommandMessage() {
		let view = ViewSpy()
		let sut = makeSUT(commandView: view)

		sut.didSaveRoutine()

		XCTAssertEqual(view.commandMessages, ["Workout saved as routine"])
	}

	func test_didFailSavingRoutine_displaysErrorMessage() {
		let view = ViewSpy()
		let sut = makeSUT(errorView: view)
		let error = NSError(domain: "test", code: 0)

		sut.didFailSavingRoutine(with: error)

		XCTAssertEqual(view.errorMessages.last, "Something went wrong. Please try again.")
	}

	// MARK: - Helpers

	private func makeSUT(
		commandView: WorkoutCommandView? = nil,
		errorView: FinishWorkoutErrorView? = nil,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> FinishWorkoutPresenter {
		let view = ViewSpy()
		let sut = FinishWorkoutPresenter(
			summaryView: view,
			loadingView: view,
			errorView: errorView ?? view,
			discardView: view,
			commandView: commandView
		)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private final class ViewSpy: FinishWorkoutSummaryView, FinishWorkoutLoadingView, FinishWorkoutErrorView, FinishWorkoutDiscardView, WorkoutCommandView {
		private(set) var errorMessages = [String?]()
		private(set) var commandMessages = [String]()

		func display(_ viewModel: FinishWorkoutSummaryViewModel) {}
		func display(_ viewModel: FinishWorkoutLoadingViewModel) {}
		func display(_ viewModel: FinishWorkoutErrorViewModel) { errorMessages.append(viewModel.message) }
		func display(_ viewModel: FinishWorkoutDiscardViewModel) {}
		func display(_ viewModel: WorkoutCommandResultViewModel) { commandMessages.append(viewModel.message) }
	}
}
