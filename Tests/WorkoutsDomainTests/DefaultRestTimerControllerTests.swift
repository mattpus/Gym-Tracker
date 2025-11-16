import XCTest
import os
@testable import WorkoutsDomain

@MainActor
final class DefaultRestTimerControllerTests: XCTestCase {
    
    func test_enable_resetsConfigurationWithoutStartingTimer() async throws {
        let exerciseID = UUID()
        let config = RestTimerConfiguration(duration: 30, exerciseID: exerciseID)
        let (sut, factory) = makeSUT()
        
        await sut.enable(for: config)
        await sut.startIfEnabled(afterSetFor: exerciseID)
        
        XCTAssertEqual(factory.count, 1)
    }
    
    func test_startIfEnabled_emitsTickUpdatesUntilCompletion() async throws {
        let exerciseID = UUID()
        let config = RestTimerConfiguration(duration: 2, exerciseID: exerciseID)
        let (sut, factory) = makeSUT()
        await sut.enable(for: config)
        
        var receivedStates = [RestTimerState]()
        let exp = expectation(description: "Wait for ticks")
        exp.expectedFulfillmentCount = 2
        await sut.observe { state in
            Task { @MainActor in
                receivedStates.append(state)
                exp.fulfill()
            }
        }
        
        await sut.startIfEnabled(afterSetFor: exerciseID)
        let scheduler = factory.scheduler(at: 0)
        await scheduler.fire()
        await scheduler.fire()
        
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssert(receivedStates.contains(RestTimerState(exerciseID: exerciseID, remaining: 0, isRunning: false)))
        XCTAssert(receivedStates.contains(RestTimerState(exerciseID: exerciseID, remaining: 1, isRunning: true)))
        
    }
    
    func test_toggle_startsAndStopsScheduler() async throws {
        let exerciseID = UUID()
        let config = RestTimerConfiguration(duration: 5, exerciseID: exerciseID)
        let (sut, factory) = makeSUT()
        await sut.enable(for: config)
        
        await sut.toggle(for: exerciseID)
        await sut.toggle(for: exerciseID)
        
        XCTAssertEqual(factory.count, 1)
        let scheduler = factory.scheduler(at: 0)
        let cancelCount = await scheduler.cancelCallCount()
        XCTAssertEqual(cancelCount, 1)
    }
    
    func test_disable_cancelsSchedulerAndNotifiesStoppedState() async throws {
        let exerciseID = UUID()
        let config = RestTimerConfiguration(duration: 5, exerciseID: exerciseID)
        let (sut, factory) = makeSUT()
        await sut.enable(for: config)
        var received = [RestTimerState]()
        let exp = expectation(description: "Wait for disable")
        await sut.observe { state in
            Task { @MainActor in
                received.append(state)
                exp.fulfill()
            }
        }
        
        await sut.startIfEnabled(afterSetFor: exerciseID)
        await sut.disable(exerciseID: exerciseID)
        
        await fulfillment(of: [exp], timeout: 1.0)
        let scheduler = factory.scheduler(at: 0)
        let cancelCount = await scheduler.cancelCallCount()
        XCTAssertEqual(cancelCount, 1)
        XCTAssertEqual(received.last, RestTimerState(exerciseID: exerciseID, remaining: 0, isRunning: false))
    }
    
    func test_handleSetCompletion_whenTimerDisabled_doesNothing() async throws {
        let (sut, factory) = makeSUT()
        
        await sut.startIfEnabled(afterSetFor: UUID())
        
        XCTAssertEqual(factory.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: DefaultRestTimerController, factory: RestTimerSchedulerFactorySpy) {
        let factory = RestTimerSchedulerFactorySpy()
        let sut = DefaultRestTimerController(schedulerFactory: factory.makeScheduler)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, factory)
    }
    
    private struct RestTimerSchedulerFactorySpy: Sendable {
        private let lock = OSAllocatedUnfairLock(initialState: [RestTimerSchedulerSpy]())
        
        func makeScheduler() -> RestTimerScheduler {
            let scheduler = RestTimerSchedulerSpy()
            lock.withLock { storage in
                storage.append(scheduler)
            }
            return scheduler
        }
        
        func scheduler(at index: Int) -> RestTimerSchedulerSpy {
            lock.withLock { $0[index] }
        }
        
        var count: Int {
            lock.withLock { $0.count }
        }
    }
    
    private struct RestTimerSchedulerSpy: RestTimerScheduler, Sendable {
        private actor State {
            var tick: (@Sendable () async -> Void)?
            var cancelCallCount = 0
            
            func setTick(_ tick: @escaping @Sendable () async -> Void) {
                self.tick = tick
            }
            
            func fire() async {
                await tick?()
            }
            
            func cancel() {
                cancelCallCount += 1
            }
            
            func cancelCount() -> Int {
                cancelCallCount
            }
        }
        
        private let state = State()
        
        func start(_ tick: @escaping @Sendable () async -> Void) {
            Task { await state.setTick(tick) }
        }
        
        func fire() async {
            await state.fire()
        }
        
        func cancel() {
            Task { await state.cancel() }
        }
        
        func cancelCallCount() async -> Int {
            await state.cancelCount()
        }
    }
}
