import XCTest
@testable import WorkoutsData

func assertThatRoutineRetrieveDeliversEmptyOnEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	expectRoutine(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatRoutineRetrieveHasNoSideEffectsOnEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	expectRoutine(sut, toRetrieveTwice: .success(.none), file: file, line: line)
}

func assertThatRoutineRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	let cache = uniqueRoutinesCache()
	insert(cache, to: sut)
	
	expectRoutine(sut, toRetrieve: .success(CachedRoutines(routines: cache.routines, timestamp: cache.timestamp)), file: file, line: line)
}

func assertThatRoutineRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	let cache = uniqueRoutinesCache()
	insert(cache, to: sut)
	
	expectRoutine(sut, toRetrieveTwice: .success(CachedRoutines(routines: cache.routines, timestamp: cache.timestamp)), file: file, line: line)
}

func assertThatRoutineInsertDeliversNoErrorOnEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	let insertionError = insert(uniqueRoutinesCache(), to: sut)
	
	XCTAssertNil(insertionError, "Expected to insert routines successfully", file: file, line: line)
}

func assertThatRoutineInsertDeliversNoErrorOnNonEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueRoutinesCache(), to: sut)
	
	let insertionError = insert(uniqueRoutinesCache(), to: sut)
	
	XCTAssertNil(insertionError, "Expected overriding routines cache not to fail", file: file, line: line)
}

func assertThatRoutineInsertOverridesPreviouslyInsertedCacheValues(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueRoutinesCache(), to: sut)
	
	let latestCache = uniqueRoutinesCache()
	insert(latestCache, to: sut)
	
	expectRoutine(sut, toRetrieve: .success(CachedRoutines(routines: latestCache.routines, timestamp: latestCache.timestamp)), file: file, line: line)
}

func assertThatRoutineDeleteDeliversNoErrorOnEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	let deletionError = deleteRoutineCache(from: sut)
	
	XCTAssertNil(deletionError, "Expected empty routines cache deletion to succeed", file: file, line: line)
}

func assertThatRoutineDeleteHasNoSideEffectsOnEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	deleteRoutineCache(from: sut)
	
	expectRoutine(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatRoutineDeleteDeliversNoErrorOnNonEmptyCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueRoutinesCache(), to: sut)
	
	let deletionError = deleteRoutineCache(from: sut)
	
	XCTAssertNil(deletionError, "Expected non-empty routines cache deletion to succeed", file: file, line: line)
}

func assertThatRoutineDeleteEmptiesPreviouslyInsertedCache(on sut: RoutineStore, file: StaticString = #filePath, line: UInt = #line) {
	insert(uniqueRoutinesCache(), to: sut)
	
	deleteRoutineCache(from: sut)
	
	expectRoutine(sut, toRetrieve: .success(.none), file: file, line: line)
}

@discardableResult
private func insert(_ cache: (routines: [LocalRoutine], timestamp: Date), to sut: RoutineStore) -> Error? {
	do {
		try sut.insert(cache.routines, timestamp: cache.timestamp)
		return nil
	} catch {
		return error
	}
}

@discardableResult
private func deleteRoutineCache(from sut: RoutineStore) -> Error? {
	do {
		try sut.deleteCachedRoutines()
		return nil
	} catch {
		return error
	}
}

private func expectRoutine(
	_ sut: RoutineStore,
	toRetrieve expectedResult: Result<CachedRoutines?, Error>,
	file: StaticString = #filePath,
	line: UInt = #line
) {
	let retrievedResult = Result { try sut.retrieve() }
	
	switch (expectedResult, retrievedResult) {
	case (.success(.none), .success(.none)), (.failure, .failure):
		break
		
	case let (.success(.some(expectedCache)), .success(.some(retrievedCache))):
		XCTAssertEqual(retrievedCache.routines, expectedCache.routines, file: file, line: line)
		XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)
		
	default:
		XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
	}
}

private func expectRoutine(
	_ sut: RoutineStore,
	toRetrieveTwice expectedResult: Result<CachedRoutines?, Error>,
	file: StaticString = #filePath,
	line: UInt = #line
) {
	expectRoutine(sut, toRetrieve: expectedResult, file: file, line: line)
	expectRoutine(sut, toRetrieve: expectedResult, file: file, line: line)
}
