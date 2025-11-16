import XCTest
@testable import WorkoutsDomain

@MainActor
final class ScheduleWorkoutUseCaseTests: XCTestCase {
	
	func test_schedule_requestsReadAndSaveFromRepository() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		
		sut.schedule(workout) { _ in }
		
		XCTAssertEqual(repository.messages, [.load, .save([workout])])
	}
	
	func test_schedule_appendsWorkoutToStoredWorkouts() {
		let existing = makeWorkout(name: "Existing")
		let newWorkout = makeWorkout(name: "New")
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([existing])
		
		expect(sut, scheduling: newWorkout, toCompleteWith: .success(()))
		
		XCTAssertEqual(repository.messages, [.load, .save([existing, newWorkout])])
	}
	
	func test_schedule_replacesExistingWorkoutWithSameID() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		let updated = Workout(id: workout.id, date: workout.date, name: "Updated", exercises: workout.exercises)
		
		expect(sut, scheduling: updated, toCompleteWith: .success(()))
		
		XCTAssertEqual(repository.messages, [.load, .save([updated])])
	}
	
	func test_schedule_deliversErrorWhenRepositoryLoadFails() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.loadResult = .failure(error)
		
		expect(sut, scheduling: makeWorkout(), toCompleteWith: .failure(error))
	}
	
	func test_schedule_deliversErrorWhenRepositorySaveFails() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.saveResult = error
		
		expect(sut, scheduling: makeWorkout(), toCompleteWith: .failure(error))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ScheduleWorkoutUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = ScheduleWorkoutUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func expect(_ sut: ScheduleWorkoutUseCase, scheduling workout: Workout, toCompleteWith expectedResult: WorkoutScheduling.Result, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for schedule")
		
		sut.schedule(workout) { receivedResult in
			switch (receivedResult, expectedResult) {
			case (.success, .success):
				break
				
			case let (.failure(received as NSError), .failure(expected as NSError)):
				XCTAssertEqual(received, expected, file: file, line: line)
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeWorkout(name: String = "Workout") -> Workout {
		Workout(date: Date(), name: name, exercises: [])
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
}
