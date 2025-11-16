import XCTest
@testable import WorkoutsData

@MainActor
final class CoreDataRoutineStoreTests: XCTestCase {
	
	func test_retrieve_deliversEmptyOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineRetrieveDeliversEmptyOnEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
		}
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineInsertDeliversNoErrorOnEmptyCache(on: sut)
		}
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineInsertDeliversNoErrorOnNonEmptyCache(on: sut)
		}
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() async throws {
		try await makeSUT { sut in
			assertThatRoutineInsertOverridesPreviouslyInsertedCacheValues(on: sut)
		}
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineDeleteDeliversNoErrorOnEmptyCache(on: sut)
		}
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineDeleteHasNoSideEffectsOnEmptyCache(on: sut)
		}
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
		}
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() async throws {
		try await makeSUT { sut in
			assertThatRoutineDeleteEmptiesPreviouslyInsertedCache(on: sut)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		_ test: @Sendable @escaping (RoutineStore) -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) async throws {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try CoreDataWorkoutStore(storeURL: storeURL, contextQueue: .main)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		await sut.perform {
			test(sut)
		}
	}
}
