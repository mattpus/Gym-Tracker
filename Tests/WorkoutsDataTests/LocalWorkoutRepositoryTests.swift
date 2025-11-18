import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class LocalWorkoutRepositoryTests: XCTestCase {
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessages.isEmpty)
	}
	
	func test_load_requestsCacheRetrieval() throws {
		let (sut, store) = makeSUT()
		
		_ = try? sut.loadWorkouts()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_deliversEmptyCollectionOnEmptyCache() throws {
		let (sut, store) = makeSUT()
		store.retrieveResult = .success(nil)
		
		let result = try sut.loadWorkouts()
		
		XCTAssertEqual(result, [])
	}
	
	func test_load_deliversCachedWorkoutsOnSuccessfulRetrieval() throws {
		let (sut, store) = makeSUT()
		let workout = makeWorkout()
		store.retrieveResult = .success(CachedWorkouts(workouts: [workout.local], timestamp: Date()))
		
		let result = try sut.loadWorkouts()
		
		XCTAssertEqual(result, [workout.model])
	}
	
	func test_load_throwsErrorOnRetrievalFailure() {
		let (sut, store) = makeSUT()
		let error = anyError()
		store.retrieveResult = .failure(error)
		
		XCTAssertThrowsError(try sut.loadWorkouts())
	}
	
	func test_save_requestsCacheDeletionBeforeInserting() {
		let (sut, store) = makeSUT()
		
		try? sut.save([])
		
		XCTAssertEqual(store.receivedMessages.first, .deleteCachedWorkouts)
	}
	
	func test_save_doesNotInsertOnDeletionError() {
		let (sut, store) = makeSUT()
		store.deleteResult = .failure(anyError())
		
		XCTAssertThrowsError(try sut.save([]))
		XCTAssertEqual(store.receivedMessages, [.deleteCachedWorkouts])
	}
	
	func test_save_insertsWorkoutsWithTimestampAfterSuccessfulDeletion() throws {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let workout = makeWorkout()
		
		try sut.save([workout.model])
		
		XCTAssertEqual(store.receivedMessages, [
			.deleteCachedWorkouts,
			.insert(workouts: [workout.local], timestamp: timestamp)
		])
	}
	
	func test_save_passesStoreInsertionErrorToCaller() {
		let (sut, store) = makeSUT()
		store.insertResult = .failure(anyError())
		
		XCTAssertThrowsError(try sut.save([]))
	}

	func test_makeExerciseSetLoggingUseCase_usesHistoryFromStore() {
		let (repository, store) = makeSUT()
		let exerciseID = UUID()
		let previousSet = ExerciseSet(order: 0, repetitions: 5, weight: 50, duration: nil)
		let previousWorkout = Workout(
			date: Date().addingTimeInterval(-3600),
			name: "Prev",
			exercises: [Exercise(id: exerciseID, name: "Bench", sets: [previousSet])]
		)
		let currentWorkout = Workout(
			date: Date(),
			name: "Today",
			exercises: [Exercise(id: exerciseID, name: "Bench", sets: [])]
		)
		store.retrieveResult = .success(CachedWorkouts(workouts: [previousWorkout, currentWorkout].toLocal(), timestamp: Date()))

		let sut = repository.makeExerciseSetLoggingUseCase()
		let request = ExerciseSetRequest(repetitions: 8, weight: 60, duration: nil)
		let exp = expectation(description: "Wait for logging")

		sut.addSet(to: currentWorkout.id, exerciseID: exerciseID, request: request) { result in
			if case let .success(logResult) = result {
				XCTAssertEqual(logResult.previousSet, previousSet)
			} else {
				XCTFail("Expected success, got \(result) instead")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalWorkoutRepository, store: WorkoutStoreSpy) {
		let store = WorkoutStoreSpy()
		let sut = LocalWorkoutRepository(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
}

final class WorkoutStoreSpy: WorkoutStore {
	enum Message: Equatable {
		case retrieve
		case deleteCachedWorkouts
		case insert(workouts: [LocalWorkout], timestamp: Date)
	}
	
	private(set) var receivedMessages = [Message]()
	var retrieveResult: Result<CachedWorkouts?, Error> = .success(nil)
	var deleteResult: Result<Void, Error> = .success(())
	var insertResult: Result<Void, Error> = .success(())
	
	func retrieve() throws -> CachedWorkouts? {
		receivedMessages.append(.retrieve)
		return try retrieveResult.get()
	}
	
	func deleteCachedWorkouts() throws {
		receivedMessages.append(.deleteCachedWorkouts)
		try deleteResult.get()
	}
	
	func insert(_ workouts: [LocalWorkout], timestamp: Date) throws {
		receivedMessages.append(.insert(workouts: workouts, timestamp: timestamp))
		try insertResult.get()
	}
}
