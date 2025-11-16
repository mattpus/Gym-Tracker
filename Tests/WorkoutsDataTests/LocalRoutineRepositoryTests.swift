import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class LocalRoutineRepositoryTests: XCTestCase {
	func test_init_doesNotMessageStore() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessages.isEmpty)
	}
	
	func test_load_requestsCacheRetrieval() throws {
		let (sut, store) = makeSUT()
		
		_ = try? sut.loadRoutines()
		
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}
	
	func test_load_deliversEmptyOnEmptyCache() throws {
		let (sut, store) = makeSUT()
		store.retrieveResult = .success(nil)
		
		let result = try sut.loadRoutines()
		
		XCTAssertEqual(result, [])
	}
	
	func test_load_deliversCachedRoutines() throws {
		let (sut, store) = makeSUT()
		let routine = makeRoutine()
		store.retrieveResult = .success(.init(routines: [routine.local], timestamp: Date()))
		
		let result = try sut.loadRoutines()
		
		XCTAssertEqual(result, [routine.model])
	}
	
	func test_load_throwsOnRetrievalError() {
		let (sut, store) = makeSUT()
		let error = anyError()
		store.retrieveResult = .failure(error)
		
		XCTAssertThrowsError(try sut.loadRoutines())
	}
	
	func test_save_deletesCacheBeforeInsert() {
		let (sut, store) = makeSUT()
		
		try? sut.save([])
		
		XCTAssertEqual(store.receivedMessages.first, .deleteCachedRoutines)
	}
	
	func test_save_doesNotInsertOnDeletionError() {
		let (sut, store) = makeSUT()
		store.deleteResult = .failure(anyError())
		
		XCTAssertThrowsError(try sut.save([]))
		XCTAssertEqual(store.receivedMessages, [.deleteCachedRoutines])
	}
	
	func test_save_insertsRoutinesWithTimestampAfterSuccessfulDeletion() throws {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let routine = makeRoutine()
		
		try sut.save([routine.model])
		
		XCTAssertEqual(store.receivedMessages, [
			.deleteCachedRoutines,
			.insert(routines: [routine.local], timestamp: timestamp)
		])
	}
	
	func test_save_propagatesInsertError() {
		let (sut, store) = makeSUT()
		store.insertResult = .failure(anyError())
		
		XCTAssertThrowsError(try sut.save([]))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalRoutineRepository, store: RoutineStoreSpy) {
		let store = RoutineStoreSpy()
		let sut = LocalRoutineRepository(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func makeRoutine() -> (model: Routine, local: LocalRoutine) {
		let sets = [
			LocalRoutineSet(id: UUID(), order: 0, repetitions: 10, weight: 135, duration: nil)
		]
		let exercises = [
			LocalRoutineExercise(id: UUID(), name: "Bench", notes: "Flat", sets: sets)
		]
		let local = LocalRoutine(id: UUID(), name: "Push", notes: "Upper", exercises: exercises)
		let model = Routine(
			id: local.id,
			name: local.name,
			notes: local.notes,
			exercises: local.exercises.map {
				RoutineExercise(
					id: $0.id,
					name: $0.name,
					notes: $0.notes,
					sets: $0.sets.map {
						RoutineSet(
							id: $0.id,
							order: $0.order,
							repetitions: $0.repetitions,
							weight: $0.weight,
							duration: $0.duration
						)
					}
				)
			}
		)
		return (model, local)
	}
	
	private func anyError() -> NSError {
		NSError(domain: "test", code: 1)
	}
}

final class RoutineStoreSpy: RoutineStore {
	enum Message: Equatable {
		case retrieve
		case deleteCachedRoutines
		case insert(routines: [LocalRoutine], timestamp: Date)
	}
	
	private(set) var receivedMessages = [Message]()
	var retrieveResult: Result<CachedRoutines?, Error> = .success(nil)
	var deleteResult: Result<Void, Error> = .success(())
	var insertResult: Result<Void, Error> = .success(())
	
	func retrieve() throws -> CachedRoutines? {
		receivedMessages.append(.retrieve)
		return try retrieveResult.get()
	}
	
	func deleteCachedRoutines() throws {
		receivedMessages.append(.deleteCachedRoutines)
		try deleteResult.get()
	}
	
	func insert(_ routines: [LocalRoutine], timestamp: Date) throws {
		receivedMessages.append(.insert(routines: routines, timestamp: timestamp))
		try insertResult.get()
	}
}
