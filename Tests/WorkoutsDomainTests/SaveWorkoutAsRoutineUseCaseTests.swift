import XCTest
@testable import WorkoutsDomain

@MainActor
final class SaveWorkoutAsRoutineUseCaseTests: XCTestCase {
	
	func test_save_appendsConvertedRoutine() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		
		let exp = expectation(description: "Wait for save")
		sut.save(workout: workout, as: nil) { result in
			switch result {
			case .success:
				break
			default:
				XCTFail("Expected success, got \(result) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(repository.savedRoutines?.count, 1)
		let routine = repository.savedRoutines?.first
		XCTAssertEqual(routine?.name, workout.name)
		XCTAssertEqual(routine?.exercises.count, workout.exercises.count)
		XCTAssertEqual(routine?.exercises.first?.sets.count, workout.exercises.first?.sets.count)
		XCTAssertNil(routine?.exercises.first?.sets.first?.repetitions)
	}
	
	func test_save_overridesNameWhenCustomNameProvided() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		
		let exp = expectation(description: "Wait for save")
		sut.save(workout: workout, as: "Custom") { _ in exp.fulfill() }
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(repository.savedRoutines?.first?.name, "Custom")
	}
	
	func test_save_propagatesRepositoryError() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.error = anyError()
		
		let exp = expectation(description: "Wait for save")
		sut.save(workout: workout, as: nil) { result in
			switch result {
			case let .failure(error as NSError):
				XCTAssertEqual(error, repository.error)
			default:
				XCTFail("Expected error")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (SaveWorkoutAsRoutineUseCase, RoutineRepositorySpy) {
		let repository = RoutineRepositorySpy()
		let sut = SaveWorkoutAsRoutineUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func makeWorkout() -> Workout {
		let sets = [
			ExerciseSet(order: 0, repetitions: 10, weight: 135),
			ExerciseSet(order: 1, repetitions: 8, weight: 185)
		]
		let exercises = [
			Exercise(name: "Bench Press", notes: "Flat", sets: sets)
		]
		return Workout(date: Date(), name: "Push", notes: "Notes", exercises: exercises)
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
	
	private final class RoutineRepositorySpy: RoutineRepository {
		var savedRoutines: [Routine]?
		var error: NSError?
		
		func save(_ routines: [Routine]) throws {
			if let error {
				throw error
			}
			savedRoutines = routines
		}
		
		func loadRoutines() throws -> [Routine] {
			if let error {
				throw error
			}
			return savedRoutines ?? []
		}
	}
}
