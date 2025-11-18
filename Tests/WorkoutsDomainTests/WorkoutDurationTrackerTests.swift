import XCTest
@testable import WorkoutsDomain

final class WorkoutDurationTrackerTests: XCTestCase {
	func test_startSchedulesTickUpdates() {
		let scheduler = SchedulerSpy()
		var now: TimeInterval = 0
		let tracker = WorkoutDurationTracker(scheduler: scheduler, currentDate: { Date(timeIntervalSince1970: now) })
		var received = [TimeInterval]()
		tracker.start(workoutID: UUID()) { received.append($0) }
		now = 5
		scheduler.fire()
		now = 10
		scheduler.fire()
		XCTAssertEqual(received, [5, 10])
	}

	func test_stopCancelsTimerAndReturnsElapsed() {
		let scheduler = SchedulerSpy()
		var now: TimeInterval = 0
		let tracker = WorkoutDurationTracker(scheduler: scheduler, currentDate: { Date(timeIntervalSince1970: now) })
		let id = UUID()
		tracker.start(workoutID: id) { _ in }
		now = 30
		let elapsed = tracker.stop(workoutID: id)
		XCTAssertEqual(elapsed, 30)
		XCTAssertEqual(scheduler.cancelCount, 1)
	}

	private final class SchedulerSpy: WorkoutDurationScheduling {
		private var handlers = [() -> Void]()
		private(set) var cancelCount = 0

		func scheduleRepeating(interval: TimeInterval, handler: @escaping () -> Void) -> CancellableTimer {
			handlers.append(handler)
			let index = handlers.count - 1
			return TimerSpy { [weak self] in
				self?.handlers[index] = {}
				self?.cancelCount += 1
			}
		}

		func fire() {
			handlers.forEach { $0() }
		}
	}

	private final class TimerSpy: CancellableTimer {
		private let onCancel: () -> Void
		init(onCancel: @escaping () -> Void) { self.onCancel = onCancel }
		func cancel() { onCancel() }
	}
}
