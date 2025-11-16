import XCTest
@testable import WorkoutsDomain

@MainActor
final class EditWorkoutUseCaseTests: XCTestCase {
	
	func test_edit_requestsReadAndSaveFromRepository() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		
		sut.edit(workout) { _ in }
		
		XCTAssertEqual(repository.messages, [.load, .save([workout])])
	}
	
	func test_edit_updatesExistingWorkout() {
		let existing = makeWorkout(name: "First")
		let updated = Workout(id: existing.id, date: existing.date, name: "Updated", exercises: existing.exercises)
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([existing])
		
		expect(sut, editing: updated, toCompleteWith: .success(()))
		
		XCTAssertEqual(repository.messages, [.load, .save([updated])])
	}
	
	func test_edit_appendsWorkoutWhenMissing() {
		let existing = makeWorkout(name: "First")
		let newWorkout = makeWorkout(name: "New")
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([existing])
		
		expect(sut, editing: newWorkout, toCompleteWith: .success(()))
		
		XCTAssertEqual(repository.messages, [.load, .save([existing, newWorkout])])
	}
	
	func test_edit_deliversLoadError() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.loadResult = .failure(error)
		
		expect(sut, editing: makeWorkout(), toCompleteWith: .failure(error))
	}
	
	func test_edit_deliversSaveError() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.saveResult = error
		
		expect(sut, editing: makeWorkout(), toCompleteWith: .failure(error))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: EditWorkoutUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = EditWorkoutUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func expect(_ sut: EditWorkoutUseCase, editing workout: Workout, toCompleteWith expectedResult: WorkoutEditing.Result, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for edit completion")
		
		sut.edit(workout) { receivedResult in
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
