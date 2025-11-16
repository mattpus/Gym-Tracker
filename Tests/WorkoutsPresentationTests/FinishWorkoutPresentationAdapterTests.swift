import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class FinishWorkoutPresentationAdapterTests: XCTestCase {
	
	func test_finish_notifiesUseCaseAndPresenter() {
		let finisher = WorkoutFinisherSpy()
		let view = FinishWorkoutViewSpy()
		let presenter = FinishWorkoutPresenter(summaryView: view, loadingView: view, errorView: view, discardView: view)
		let sut = FinishWorkoutPresentationAdapter(finisher: finisher)
		sut.presenter = presenter
		let workoutID = UUID()
		let endDate = Date()
		let summary = WorkoutSummary(
			workout: Workout(id: workoutID, date: Date(), name: "Push", exercises: []),
			stats: WorkoutStats(totalSets: 1, totalVolume: 50, duration: 60)
		)
		
		sut.finishWorkout(id: workoutID, endDate: endDate)
		finisher.completeFinish(with: .success(summary))
		
		XCTAssertEqual(finisher.finishMessages.count, 1)
		XCTAssertEqual(finisher.finishMessages.first?.id, workoutID)
		XCTAssertEqual(finisher.finishMessages.first?.date, endDate)
		XCTAssertEqual(view.summaries, [.from(summary)])
	}
	
	func test_finish_deliversErrorToPresenter() {
		let finisher = WorkoutFinisherSpy()
		let view = FinishWorkoutViewSpy()
		let presenter = FinishWorkoutPresenter(summaryView: view, loadingView: view, errorView: view, discardView: view)
		let sut = FinishWorkoutPresentationAdapter(finisher: finisher)
		sut.presenter = presenter
		let error = anyError()
		
		sut.finishWorkout(id: UUID(), endDate: Date())
		finisher.completeFinish(with: .failure(error))
		
		XCTAssertEqual(view.errors.last?.message, "Something went wrong. Please try again.")
	}
	
	func test_discard_notifiesPresenterOnSuccess() {
		let finisher = WorkoutFinisherSpy()
		let view = FinishWorkoutViewSpy()
		let presenter = FinishWorkoutPresenter(summaryView: view, loadingView: view, errorView: view, discardView: view)
		let sut = FinishWorkoutPresentationAdapter(finisher: finisher)
		sut.presenter = presenter
		
		sut.discardWorkout(id: UUID())
		finisher.completeDiscard(with: .success(()))
		
		XCTAssertEqual(view.discards.last, .init(shouldShowConfirmation: false, didDiscard: true))
	}
	
	// MARK: - Helpers
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
	
	private final class WorkoutFinisherSpy: WorkoutFinishing {
		private(set) var finishMessages = [(id: UUID, date: Date)]()
		private(set) var discardMessages = [UUID]()
		private var finishCompletions = [(FinishResult) -> Void]()
		private var discardCompletions = [(DiscardResult) -> Void]()

		func finish(workoutID: UUID, at endDate: Date, completion: @escaping (FinishResult) -> Void) {
			finishMessages.append((workoutID, endDate))
			finishCompletions.append(completion)
		}

		func discard(workoutID: UUID, completion: @escaping (DiscardResult) -> Void) {
			discardMessages.append(workoutID)
			discardCompletions.append(completion)
		}

		func completeFinish(with result: FinishResult, at index: Int = 0) {
			finishCompletions[index](result)
		}

		func completeDiscard(with result: DiscardResult, at index: Int = 0) {
			discardCompletions[index](result)
		}
	}

	private final class FinishWorkoutViewSpy: FinishWorkoutSummaryView, FinishWorkoutLoadingView, FinishWorkoutErrorView, FinishWorkoutDiscardView {
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
