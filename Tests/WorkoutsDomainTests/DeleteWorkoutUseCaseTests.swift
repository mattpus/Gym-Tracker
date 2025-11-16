import XCTest
@testable import WorkoutsDomain

@MainActor
final class DeleteWorkoutUseCaseTests: XCTestCase {
	
	func test_delete_requestsReadAndSaveFromRepository() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		repository.loadResult = .success([workout])
		
		sut.delete(workoutID: workout.id) { _ in }
		
		XCTAssertEqual(repository.messages, [.load, .save([])])
	}
	
	func test_delete_removesWorkoutFromRepository() {
		let workout1 = makeWorkout(name: "First")
		let workout2 = makeWorkout(name: "Second")
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout1, workout2])
		
		expect(sut, deleting: workout1.id, toCompleteWith: .success(()))
		
		XCTAssertEqual(repository.messages, [.load, .save([workout2])])
	}
	
	func test_delete_deliversLoadError() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.loadResult = .failure(error)
		
		expect(sut, deleting: UUID(), toCompleteWith: .failure(error))
	}
	
	func test_delete_deliversSaveError() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.saveResult = error
		
		expect(sut, deleting: UUID(), toCompleteWith: .failure(error))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: DeleteWorkoutUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = DeleteWorkoutUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func expect(_ sut: DeleteWorkoutUseCase, deleting workoutID: UUID, toCompleteWith expectedResult: WorkoutDeleting.Result, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for delete completion")
		
		sut.delete(workoutID: workoutID) { receivedResult in
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
