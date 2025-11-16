import XCTest
@testable import WorkoutsData

func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
}

func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	let cache = uniqueWorkoutsCache()
	insert(cache, to: sut)
	
	expect(sut, toRetrieve: .success(CachedWorkouts(workouts: cache.workouts, timestamp: cache.timestamp)), file: file, line: line)
}

func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	let cache = uniqueWorkoutsCache()
	insert(cache, to: sut)
	
	expect(sut, toRetrieveTwice: .success(CachedWorkouts(workouts: cache.workouts, timestamp: cache.timestamp)), file: file, line: line)
}

func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	let insertionError = insert(uniqueWorkoutsCache(), to: sut)
	
	XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
}

func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueWorkoutsCache(), to: sut)
	
	let insertionError = insert(uniqueWorkoutsCache(), to: sut)
	
	XCTAssertNil(insertionError, "Expected overriding cache not to fail", file: file, line: line)
}

func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueWorkoutsCache(), to: sut)
	
	let latestCache = uniqueWorkoutsCache()
	insert(latestCache, to: sut)
	
	expect(sut, toRetrieve: .success(CachedWorkouts(workouts: latestCache.workouts, timestamp: latestCache.timestamp)), file: file, line: line)
}

func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	let deletionError = deleteCache(from: sut)
	
	XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
}

func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	deleteCache(from: sut)
	
	expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueWorkoutsCache(), to: sut)
	
	let deletionError = deleteCache(from: sut)
	
	XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
}

func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: WorkoutStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueWorkoutsCache(), to: sut)
	
	deleteCache(from: sut)
	
	expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

@discardableResult
func insert(_ cache: (workouts: [LocalWorkout], timestamp: Date), to sut: WorkoutStore) -> Error? {
	do {
		try sut.insert(cache.workouts, timestamp: cache.timestamp)
		return nil
	} catch {
		return error
	}
}

@discardableResult
func deleteCache(from sut: WorkoutStore) -> Error? {
	do {
		try sut.deleteCachedWorkouts()
		return nil
	} catch {
		return error
	}
}

func expect(_ sut: WorkoutStore, toRetrieveTwice expectedResult: Result<CachedWorkouts?, Error>, file: StaticString = #filePath, line: UInt = #line) {
	expect(sut, toRetrieve: expectedResult, file: file, line: line)
	expect(sut, toRetrieve: expectedResult, file: file, line: line)
}

func expect(_ sut: WorkoutStore, toRetrieve expectedResult: Result<CachedWorkouts?, Error>, file: StaticString = #filePath, line: UInt = #line) {
	let retrievedResult = Result { try sut.retrieve() }
	
	switch (expectedResult, retrievedResult) {
	case (.success(.none), .success(.none)), (.failure, .failure):
		break
		
	case let (.success(.some(expectedCache)), .success(.some(retrievedCache))):
		XCTAssertEqual(retrievedCache.workouts, expectedCache.workouts, file: file, line: line)
		XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)
		
	default:
		XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
	}
}
