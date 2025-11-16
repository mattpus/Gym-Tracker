import XCTest
@testable import WorkoutsDomain

@MainActor
final class StartRoutineUseCaseTests: XCTestCase {
	
	func test_startRoutine_deliversErrorWhenRoutineNotFound() {
		let (sut, routines, scheduler) = makeSUT()
		routines.stubbedRoutines = []
		
		let exp = expectation(description: "Wait for completion")
		sut.startRoutine(id: UUID()) { result in
			switch result {
			case let .failure(error as StartRoutineUseCase.Error):
				XCTAssertEqual(error, .routineNotFound)
			default:
				XCTFail("Expected routineNotFound error, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertTrue(scheduler.scheduledWorkouts.isEmpty)
	}
	
	func test_startRoutine_deliversRepositoryError() {
		let (sut, routines, scheduler) = makeSUT()
		let error = anyError()
		routines.error = error
		
		let exp = expectation(description: "Wait for completion")
		sut.startRoutine(id: UUID()) { result in
			switch result {
			case let .failure(received as NSError):
				XCTAssertEqual(received, error)
			default:
				XCTFail("Expected repository error, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertTrue(scheduler.scheduledWorkouts.isEmpty)
	}
	
	func test_startRoutine_schedulesWorkoutMirroringRoutine() {
		let routine = makeRoutine()
		let timestamp = Date()
		let (sut, routines, scheduler) = makeSUT(currentDate: { timestamp })
		routines.stubbedRoutines = [routine]
		
		let exp = expectation(description: "Wait for completion")
		sut.startRoutine(id: routine.id) { result in
			switch result {
			case .success:
				break
			default:
				XCTFail("Expected success, got \(result) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		let scheduled = scheduler.scheduledWorkouts.first
		XCTAssertEqual(scheduled?.name, routine.name)
		XCTAssertEqual(scheduled?.notes, routine.notes)
		XCTAssertEqual(scheduled?.date, timestamp)
		XCTAssertEqual(scheduled?.exercises.map(\.name), routine.exercises.map(\.name))
		XCTAssertEqual(scheduled?.exercises.first?.sets.count, routine.exercises.first?.sets.count)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (StartRoutineUseCase, RoutineRepositorySpy, WorkoutSchedulerSpy) {
		let routines = RoutineRepositorySpy()
		let scheduler = WorkoutSchedulerSpy()
		let sut = StartRoutineUseCase(
			routineRepository: routines,
			workoutScheduler: scheduler,
			currentDate: currentDate,
			uuid: UUID.init
		)
		trackForMemoryLeaks(routines, file: file, line: line)
		trackForMemoryLeaks(scheduler, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, routines, scheduler)
	}
	
	private func makeRoutine() -> Routine {
		let sets = [
			RoutineSet(order: 0, repetitions: 10, weight: 95, duration: nil)
		]
		let exercises = [
			RoutineExercise(name: "Bench Press", notes: "Flat", sets: sets)
		]
		return Routine(name: "Push", notes: "Upper body", exercises: exercises)
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
	
	private final class RoutineRepositorySpy: RoutineRepository {
		var stubbedRoutines: [Routine] = []
		var error: Error?
		
		func save(_ routines: [Routine]) throws {}
		
		func loadRoutines() throws -> [Routine] {
			if let error {
				throw error
			}
			return stubbedRoutines
		}
	}
	
	private final class WorkoutSchedulerSpy: WorkoutScheduling {
		private(set) var scheduledWorkouts = [Workout]()
		
		func schedule(_ workout: Workout, completion: @escaping (WorkoutScheduling.Result) -> Void) {
			scheduledWorkouts.append(workout)
			completion(.success(()))
		}
	}
}
