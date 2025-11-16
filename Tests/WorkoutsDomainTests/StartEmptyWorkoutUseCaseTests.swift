import XCTest
@testable import WorkoutsDomain

@MainActor
final class StartEmptyWorkoutUseCaseTests: XCTestCase {
	
	func test_startEmptyWorkout_schedulesWorkoutWithDefaultName() {
		let scheduler = WorkoutSchedulerSpy()
		let sut = StartEmptyWorkoutUseCase(scheduler: scheduler, currentDate: Date.init)
		let exp = expectation(description: "Wait for schedule")
		
		sut.startEmptyWorkout(named: nil) { result in
			switch result {
			case .success:
				break
			default:
				XCTFail("Expected success")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(scheduler.scheduled.count, 1)
		XCTAssertEqual(scheduler.scheduled.first?.name, "Untitled Workout")
		XCTAssertTrue(scheduler.scheduled.first?.exercises.isEmpty == true)
	}
	
	func test_startEmptyWorkout_usesProvidedName() {
		let scheduler = WorkoutSchedulerSpy()
		let sut = StartEmptyWorkoutUseCase(scheduler: scheduler, currentDate: Date.init)
		let exp = expectation(description: "Wait for schedule")
		
		sut.startEmptyWorkout(named: "Pull") { _ in exp.fulfill() }
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(scheduler.scheduled.first?.name, "Pull")
	}
	
	private final class WorkoutSchedulerSpy: WorkoutScheduling {
		private(set) var scheduled = [Workout]()
		
		func schedule(_ workout: Workout, completion: @escaping (WorkoutScheduling.Result) -> Void) {
			scheduled.append(workout)
			completion(.success(()))
		}
	}
}
