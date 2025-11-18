import XCTest
@testable import WorkoutsPresentation

final class WorkoutDurationPresenterTests: XCTestCase {
	func test_formatsUnderHour() {
		let view = ViewSpy()
		let sut = WorkoutDurationPresenter(view: view)
		sut.didUpdateDuration(125)
		XCTAssertEqual(view.messages, [.init(formattedTime: "02:05")])
	}

	func test_formatsWithHours() {
		let view = ViewSpy()
		let sut = WorkoutDurationPresenter(view: view)
		sut.didUpdateDuration(3665)
		XCTAssertEqual(view.messages, [.init(formattedTime: "1:01:05")])
	}

	private final class ViewSpy: WorkoutDurationView {
		private(set) var messages = [WorkoutDurationViewModel]()
		func display(_ viewModel: WorkoutDurationViewModel) { messages.append(viewModel) }
	}
}
