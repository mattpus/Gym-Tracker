import XCTest
@testable import WorkoutsDomain

@MainActor
final class CreateRoutineUseCaseTests: XCTestCase {
	
	func test_create_withEmptyName_failsAndSkipsRepository() {
		let (sut, repository) = makeSUT()
		let routine = Routine(name: "   ", exercises: [makeExercise()])
		
		expect(sut, toCompleteWith: .failure(CreateRoutineUseCase.Error.emptyName), for: routine)
		
		XCTAssertTrue(repository.messages.isEmpty)
	}
	
	func test_create_withNoExercises_failsAndSkipsRepository() {
		let (sut, repository) = makeSUT()
		let routine = Routine(name: "Push", exercises: [])
		
		expect(sut, toCompleteWith: .failure(CreateRoutineUseCase.Error.emptyExercises), for: routine)
		
		XCTAssertTrue(repository.messages.isEmpty)
	}
	
	func test_create_onRepositoryLoadError_fails() {
		let loadError = anyError()
		let (sut, repository) = makeSUT()
		repository.loadResult = .failure(loadError)
		
		expect(sut, toCompleteWith: .failure(loadError), for: makeRoutine())
	}
	
	func test_create_onRepositorySaveError_fails() {
		let saveError = anyError()
		let (sut, repository) = makeSUT()
		repository.saveError = saveError
		
		expect(sut, toCompleteWith: .failure(saveError), for: makeRoutine())
	}
	
	func test_create_withValidRoutine_loadsAndSavesReplacingExistingRoutine() {
		let routine = makeRoutine()
		let (sut, repository) = makeSUT()
		let existing = Routine(
			id: routine.id,
			name: "Old",
			notes: nil,
			exercises: [makeExercise()]
		)
		repository.loadResult = .success([existing])
		
		expect(sut, toCompleteWith: .success(()), for: routine)
		
		XCTAssertEqual(repository.messages, [
			.load,
			.save([routine])
		])
	}
	
	func test_create_appendsRoutineWhenRepositoryIsEmpty() {
		let routine = makeRoutine()
		let (sut, repository) = makeSUT()
		
		expect(sut, toCompleteWith: .success(()), for: routine)
		
		XCTAssertEqual(repository.messages, [
			.load,
			.save([routine])
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (CreateRoutineUseCase, RoutineRepositorySpy) {
		let repository = RoutineRepositorySpy()
		let sut = CreateRoutineUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func makeRoutine() -> Routine {
		Routine(name: "Push", notes: "Upper body", exercises: [makeExercise()])
	}
	
	private func makeExercise() -> RoutineExercise {
		RoutineExercise(name: "Bench Press", notes: "Flat", sets: [makeSet()])
	}
	
	private func makeSet() -> RoutineSet {
		RoutineSet(order: 0, repetitions: 10, weight: 135, duration: nil)
	}
	
	private func expect(
		_ sut: CreateRoutineUseCase,
		toCompleteWith expectedResult: RoutineBuilding.Result,
		for routine: Routine,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for completion")
		
		sut.create(routine) { receivedResult in
			switch (receivedResult, expectedResult) {
			case (.success, .success):
				break
				
			case let (.failure(received), .failure(expected)):
				switch (received, expected) {
				case let (lhs as CreateRoutineUseCase.Error, rhs as CreateRoutineUseCase.Error):
					XCTAssertEqual(lhs, rhs, file: file, line: line)
				default:
					XCTAssertEqual(received.localizedDescription, expected.localizedDescription, file: file, line: line)
				}
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 1)
	}
	
	private final class RoutineRepositorySpy: RoutineRepository {
		enum Message: Equatable {
			case load
			case save([Routine])
		}
		
		private(set) var messages = [Message]()
		var loadResult: Result<[Routine], Error> = .success([])
		var saveError: Error?
		
		func save(_ routines: [Routine]) throws {
			messages.append(.save(routines))
			if let saveError {
				throw saveError
			}
		}
		
		func loadRoutines() throws -> [Routine] {
			messages.append(.load)
			return try loadResult.get()
		}
	}
}
