import XCTest
@testable import WorkoutsDomain

@MainActor
final class ExerciseSetLoggingUseCaseTests: XCTestCase {
	
	func test_addSet_requestsLoadAndSave() {
		let workout = makeWorkout()
		let exerciseID = workout.exercises[0].id
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		
		sut.addSet(to: workout.id, exerciseID: exerciseID, request: makeRequest()) { _ in }
		
		XCTAssertEqual(repository.messages.count, 2)
		XCTAssertEqual(repository.messages.first, .load)
		XCTAssertEqual(repository.messages.last?.savedWorkouts?.count, 1)
	}
	
	func test_addSet_appendsSetWithIncrementedOrder() {
		let workout = makeWorkout(exercises: [
			Exercise(name: "Bench", sets: [
				ExerciseSet(order: 0, repetitions: 8, weight: 100, duration: nil)
			])
		])
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		let request = ExerciseSetRequest(repetitions: 10, weight: 105, duration: nil)
		
		var receivedResult: ExerciseSetLogResult?
		sut.addSet(to: workout.id, exerciseID: workout.exercises[0].id, request: request) { result in
			receivedResult = try? result.get()
		}
		
		XCTAssertEqual(receivedResult?.set.order, 1)
		XCTAssertEqual(receivedResult?.set.repetitions, 10)
		XCTAssertEqual(receivedResult?.exercise.sets.count, 2)
	}
	
	func test_addSet_deliversPreviousSetFromHistoryProvider() {
		let exerciseID = UUID()
		let previousSet = ExerciseSet(order: 0, repetitions: 5, weight: 50, duration: nil)
		let workout = makeWorkout(exercises: [
			Exercise(id: exerciseID, name: "Bench", sets: [])
		])
		let (sut, repository, history) = makeSUT()
		repository.loadResult = .success([workout])
		history.result = .success(previousSet)
		
		var receivedResult: ExerciseSetLogResult?
		sut.addSet(to: workout.id, exerciseID: exerciseID, request: makeRequest()) { result in
			receivedResult = try? result.get()
		}
		
		XCTAssertEqual(receivedResult?.previousSet, previousSet)
	}

	func test_addSet_requestsHistoryForExerciseBeforeWorkoutDate() {
		let exercise = Exercise(id: UUID(), name: "Bench", sets: [])
		let workout = makeWorkout(exercises: [exercise])
		let (sut, repository, history) = makeSUT()
		repository.loadResult = .success([workout])

		sut.addSet(to: workout.id, exerciseID: exercise.id, request: makeRequest()) { _ in }

		XCTAssertEqual(history.messages, [.previous(exercise.id, workout.date)])
	}

	func test_updateSet_requestsHistoryForExerciseBeforeWorkoutDate() {
		let set = ExerciseSet(id: UUID(), order: 0, repetitions: 5, weight: 50, duration: nil)
		let exercise = Exercise(id: UUID(), name: "Bench", sets: [set])
		let workout = makeWorkout(exercises: [exercise])
		let (sut, repository, history) = makeSUT()
		repository.loadResult = .success([workout])

		sut.updateSet(in: workout.id, exerciseID: exercise.id, setID: set.id, request: makeRequest()) { _ in }

		XCTAssertEqual(history.messages, [.previous(exercise.id, workout.date)])
	}

	func test_addSet_deliversErrorWhenHistoryProviderFails() {
		let exercise = Exercise(id: UUID(), name: "Bench", sets: [])
		let workout = makeWorkout(exercises: [exercise])
		let (sut, repository, history) = makeSUT()
		repository.loadResult = .success([workout])
		let error = anyError()
		history.result = .failure(error)

		var receivedError: Error?
		sut.addSet(to: workout.id, exerciseID: exercise.id, request: makeRequest()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}

		XCTAssertEqual(receivedError as NSError?, error)
	}
	
	func test_addSet_throwsWhenWorkoutNotFound() {
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([])
		
		var receivedError: Error?
		sut.addSet(to: UUID(), exerciseID: UUID(), request: makeRequest()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}
		
		XCTAssertNotNil(receivedError)
	}
	
	func test_updateSet_throwsWhenSetMissing() {
		let workout = makeWorkout(exercises: [Exercise(name: "Bench", sets: [])])
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		
		var receivedError: Error?
		sut.updateSet(in: workout.id, exerciseID: workout.exercises[0].id, setID: UUID(), request: makeRequest()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}
		
		XCTAssertNotNil(receivedError)
	}
	
	func test_deleteSet_throwsWhenSetMissing() {
		let workout = makeWorkout(exercises: [Exercise(name: "Bench", sets: [])])
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		
		var receivedError: Error?
		sut.deleteSet(in: workout.id, exerciseID: workout.exercises[0].id, setID: UUID()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}
		
		XCTAssertNotNil(receivedError)
	}
	
	func test_updateSet_updatesExistingValues() {
		let set = ExerciseSet(id: UUID(), order: 0, repetitions: 5, weight: 50, duration: nil)
		let exercise = Exercise(name: "Bench", sets: [set])
		let workout = makeWorkout(exercises: [exercise])
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		
		var receivedResult: ExerciseSetLogResult?
		let request = ExerciseSetRequest(repetitions: 8, weight: 60, duration: nil)
		sut.updateSet(in: workout.id, exerciseID: exercise.id, setID: set.id, request: request) { result in
			receivedResult = try? result.get()
		}
		
		XCTAssertEqual(receivedResult?.set.repetitions, 8)
		XCTAssertEqual(receivedResult?.set.weight, 60)
	}
	
	func test_deleteSet_removesSetAndReorders() {
		let set1 = ExerciseSet(id: UUID(), order: 0, repetitions: 5, weight: 50, duration: nil)
		let set2 = ExerciseSet(id: UUID(), order: 1, repetitions: 6, weight: 55, duration: nil)
		let exercise = Exercise(name: "Bench", sets: [set1, set2])
		let workout = makeWorkout(exercises: [exercise])
		let (sut, repository, _) = makeSUT()
		repository.loadResult = .success([workout])
		
		var receivedResult: ExerciseSetDeletionResult?
		sut.deleteSet(in: workout.id, exerciseID: exercise.id, setID: set1.id) { result in
			receivedResult = try? result.get()
		}
		
		XCTAssertEqual(receivedResult?.exercise.sets.count, 1)
		XCTAssertEqual(receivedResult?.exercise.sets.first?.order, 0)
		XCTAssertEqual(receivedResult?.exercise.sets.first?.id, set2.id)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ExerciseSetLoggingUseCase, repository: WorkoutRepositorySpy, history: ExerciseHistoryProviderSpy) {
		let repository = WorkoutRepositorySpy()
		let history = ExerciseHistoryProviderSpy()
		let sut = ExerciseSetLoggingUseCase(repository: repository, historyProvider: history)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(history, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository, history)
	}
	
	private func makeRequest() -> ExerciseSetRequest {
		ExerciseSetRequest(repetitions: 10, weight: 100, duration: nil)
	}
	
	private func makeWorkout(
		id: UUID = UUID(),
		date: Date = Date(),
		name: String = "Workout",
		notes: String? = nil,
		exercises: [Exercise] = [Exercise(name: "Bench", sets: [])]
	) -> Workout {
		Workout(id: id, date: date, name: name, notes: notes, exercises: exercises)
	}

	private func anyError() -> NSError {
		NSError(domain: "test", code: 0)
	}
}

private final class ExerciseHistoryProviderSpy: ExerciseHistoryProviding {
	enum Message: Equatable {
		case previous(UUID, Date)
	}

	private(set) var messages = [Message]()
	var result: Result<ExerciseSet?, Swift.Error> = .success(nil)

	func previousSet(for exerciseID: UUID, before date: Date) throws -> ExerciseSet? {
		messages.append(.previous(exerciseID, date))
		return try result.get()
	}
}
