import XCTest
@testable import WorkoutsDomain

@MainActor
final class LoadRoutinesUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageRepository() {
		let (_, repository) = makeSUT()
		
		XCTAssertTrue(repository.messages.isEmpty)
	}
	
	func test_load_requestsRoutinesFromRepository() {
		let (sut, repository) = makeSUT()
		
		sut.load { _ in }
		
		XCTAssertEqual(repository.messages, [.load])
	}
	
	func test_load_deliversRoutinesOnSuccess() {
		let (sut, repository) = makeSUT()
		let routines = [Routine(name: "Push", exercises: [RoutineExercise(name: "Bench", sets: [RoutineSet(order: 0)])])]
		repository.stubbedRoutines = routines
		
		let exp = expectation(description: "Wait for load")
		sut.load { result in
			switch result {
			case let .success(received):
				XCTAssertEqual(received, routines)
			default:
				XCTFail("Expected success, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_load_deliversErrorOnFailure() {
		let (sut, repository) = makeSUT()
		let error = NSError(domain: "test", code: 1)
		repository.error = error
		
		let exp = expectation(description: "Wait for load")
		sut.load { result in
			switch result {
			case let .failure(received as NSError):
				XCTAssertEqual(received, error)
			default:
				XCTFail("Expected failure, got \(result) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LoadRoutinesUseCase, RoutineRepositorySpy) {
		let repository = RoutineRepositorySpy()
		let sut = LoadRoutinesUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private final class RoutineRepositorySpy: RoutineRepository {
		enum Message: Equatable {
			case load
		}
		
		private(set) var messages = [Message]()
		var stubbedRoutines: [Routine] = []
		var error: Error?
		
		func save(_ routines: [Routine]) throws {}
		
		func loadRoutines() throws -> [Routine] {
			messages.append(.load)
			if let error {
				throw error
			}
			return stubbedRoutines
		}
	}
}
