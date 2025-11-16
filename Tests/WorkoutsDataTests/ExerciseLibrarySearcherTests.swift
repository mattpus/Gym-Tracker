import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class ExerciseLibrarySearcherTests: XCTestCase {
	
	func test_init_loadsLibraryFromResources() throws {
		let sut = try makeSUT()
		
		let exp = expectation(description: "Wait for search")
		sut.search(query: "Bench") { result in
			let items = try? result.get()
			XCTAssertEqual(items?.first?.name, "Bench Press")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_search_withEmptyQuery_returnsEmpty() throws {
		let sut = try makeSUT()
		
		let exp = expectation(description: "Wait for search")
		sut.search(query: "   ") { result in
			let items = try? result.get()
			XCTAssertEqual(items, [])
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_search_filtersByNameOrMuscle() throws {
		let sut = try makeSUT()
		
		let exp = expectation(description: "Wait for search")
		sut.search(query: "back") { result in
			let items = try? result.get()
			XCTAssertEqual(items?.first?.name, "Deadlift")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> LocalExerciseLibrarySearcher {
		let sut = try LocalExerciseLibrarySearcher()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
