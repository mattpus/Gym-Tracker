import XCTest
@testable import WorkoutsDomain

@MainActor
final class LoadWorkoutsUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageRepository() {
		let (_, repository) = makeSUT()
		
		XCTAssertTrue(repository.messages.isEmpty)
	}
	
	func test_load_requestsWorkoutsFromRepository() {
		let (sut, repository) = makeSUT()
		
		sut.load { _ in }
		
		XCTAssertEqual(repository.messages, [.load])
	}
	
	func test_load_deliversRepositoryResult() {
		let (sut, repository) = makeSUT()
		let workouts = [makeWorkout(name: "Push")]
		repository.loadResult = .success(workouts)
		
		expect(sut, toCompleteWith: .success(workouts))
	}
	
	func test_load_deliversRepositoryError() {
		let (sut, repository) = makeSUT()
		let error = anyError()
		repository.loadResult = .failure(error)
		
		expect(sut, toCompleteWith: .failure(error))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadWorkoutsUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = LoadWorkoutsUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func expect(_ sut: LoadWorkoutsUseCase, toCompleteWith expectedResult: WorkoutsLoading.Result, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(received), .success(expected)):
				XCTAssertEqual(received, expected, file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeWorkout(name: String) -> Workout {
		Workout(date: Date(), name: name, exercises: [])
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
}
