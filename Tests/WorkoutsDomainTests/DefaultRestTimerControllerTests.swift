import XCTest
@testable import WorkoutsDomain

@MainActor
final class DefaultRestTimerControllerTests: XCTestCase {
	
	func test_enable_resetsConfigurationWithoutStartingTimer() {
		let exerciseID = UUID()
		let config = RestTimerConfiguration(duration: 30, exerciseID: exerciseID)
		let (sut, factory) = makeSUT()
		
		sut.enable(for: config)
		sut.startIfEnabled(afterSetFor: exerciseID)
		
		XCTAssertEqual(factory.schedulers.count, 1)
	}
	
	func test_startIfEnabled_emitsTickUpdatesUntilCompletion() {
		let exerciseID = UUID()
		let config = RestTimerConfiguration(duration: 2, exerciseID: exerciseID)
		let (sut, factory) = makeSUT()
		sut.enable(for: config)
		
		var receivedStates = [RestTimerState]()
		let exp = expectation(description: "Wait for ticks")
		exp.expectedFulfillmentCount = 2
		sut.observe { state in
			receivedStates.append(state)
			exp.fulfill()
		}
		
		sut.startIfEnabled(afterSetFor: exerciseID)
		factory.schedulers[0].fire()
		factory.schedulers[0].fire()
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertEqual(receivedStates, [
			RestTimerState(exerciseID: exerciseID, remaining: 1, isRunning: true),
			RestTimerState(exerciseID: exerciseID, remaining: 0, isRunning: false)
		])
	}
	
	func test_toggle_startsAndStopsScheduler() {
		let exerciseID = UUID()
		let config = RestTimerConfiguration(duration: 5, exerciseID: exerciseID)
		let (sut, factory) = makeSUT()
		sut.enable(for: config)
		
		sut.toggle(for: exerciseID)
		sut.toggle(for: exerciseID)
		
		XCTAssertEqual(factory.schedulers.count, 1)
		XCTAssertEqual(factory.schedulers[0].cancelCallCount, 1)
	}
	
	func test_disable_cancelsSchedulerAndNotifiesStoppedState() {
		let exerciseID = UUID()
		let config = RestTimerConfiguration(duration: 5, exerciseID: exerciseID)
		let (sut, factory) = makeSUT()
		sut.enable(for: config)
		var received = [RestTimerState]()
		let exp = expectation(description: "Wait for disable")
		sut.observe { state in
			received.append(state)
			exp.fulfill()
		}
		
		sut.startIfEnabled(afterSetFor: exerciseID)
		sut.disable(exerciseID: exerciseID)
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertEqual(factory.schedulers[0].cancelCallCount, 1)
		XCTAssertEqual(received.last, RestTimerState(exerciseID: exerciseID, remaining: 0, isRunning: false))
	}
	
	func test_handleSetCompletion_whenTimerDisabled_doesNothing() {
		let (sut, factory) = makeSUT()
		
		sut.startIfEnabled(afterSetFor: UUID())
		
		XCTAssertTrue(factory.schedulers.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: DefaultRestTimerController, factory: RestTimerSchedulerFactorySpy) {
		let queue = DispatchQueue(label: "rest-timer-tests")
		let factory = RestTimerSchedulerFactorySpy(queue: queue)
		let sut = DefaultRestTimerController(queue: queue, schedulerFactory: factory.makeScheduler)
		trackForMemoryLeaks(factory, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, factory)
	}
	
	private final class RestTimerSchedulerFactorySpy {
		private let queue: DispatchQueue
		private(set) var schedulers = [RestTimerSchedulerSpy]()
		
		init(queue: DispatchQueue) {
			self.queue = queue
		}
		
		func makeScheduler(queue: DispatchQueue) -> RestTimerScheduler {
			let scheduler = RestTimerSchedulerSpy(queue: queue)
			schedulers.append(scheduler)
			return scheduler
		}
	}
	
	private final class RestTimerSchedulerSpy: RestTimerScheduler {
		private let queue: DispatchQueue
		private var tick: (() -> Void)?
		private(set) var cancelCallCount = 0
		
		init(queue: DispatchQueue) {
			self.queue = queue
		}
		
		func start(_ tick: @escaping () -> Void) {
			self.tick = tick
		}
		
		func fire() {
			if let tick {
				queue.async {
					tick()
				}
				queue.sync {}
			}
		}
		
		func cancel() {
			cancelCallCount += 1
		}
	}
}
