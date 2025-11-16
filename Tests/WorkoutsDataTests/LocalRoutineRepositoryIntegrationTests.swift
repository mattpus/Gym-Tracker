import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class LocalRoutineRepositoryIntegrationTests: XCTestCase {
	
	override func setUp() async throws {
		try await super.setUp()
		
		deleteStoreArtifacts()
	}
	
	override func tearDown() async throws {
		try await super.tearDown()
		
		deleteStoreArtifacts()
	}
	
	func test_load_deliversNoRoutinesOnEmptyStore() throws {
		let sut = try makeSUT()
		
		let loaded = try sut.loadRoutines()
		
		XCTAssertEqual(loaded, [])
	}
	
	func test_load_deliversRoutinesSavedOnASeparateInstance() throws {
		let routines = [uniqueRoutine(), uniqueRoutine(name: "Leg Day")]
		let saveSUT = try makeSUT()
		let loadSUT = try makeSUT()
		
		try saveSUT.save(routines)
		let loaded = try loadSUT.loadRoutines()
		
		XCTAssertEqual(loaded, routines)
	}
	
	func test_save_overridesRoutinesSavedOnASeparateInstance() throws {
		let firstSaveSUT = try makeSUT()
		let lastSaveSUT = try makeSUT()
		let loadSUT = try makeSUT()
		let firstRoutines = [uniqueRoutine(name: "Push")]
		let latestRoutines = [uniqueRoutine(name: "Pull")]
		
		try firstSaveSUT.save(firstRoutines)
		try lastSaveSUT.save(latestRoutines)
		let loaded = try loadSUT.loadRoutines()
		
		XCTAssertEqual(loaded, latestRoutines)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) throws -> LocalRoutineRepository {
		let store = try CoreDataWorkoutStore(storeURL: testSpecificStoreURL(), contextQueue: .main)
		let sut = LocalRoutineRepository(store: store, currentDate: Date.init)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func uniqueRoutine(name: String = "Routine") -> Routine {
		let sets = [
			RoutineSet(order: 0, repetitions: 10, weight: 50, duration: 60)
		]
		let exercises = [
			RoutineExercise(name: "Bench", notes: "Incline", sets: sets)
		]
		return Routine(
			name: name,
			notes: "Notes",
			exercises: exercises
		)
	}
	
	private func deleteStoreArtifacts() {
		let url = testSpecificStoreURL()
		let manager = FileManager.default
		try? manager.removeItem(at: url)
		try? manager.removeItem(at: url.appendingPathExtension("shm"))
		try? manager.removeItem(at: url.appendingPathExtension("wal"))
	}
	
	private func testSpecificStoreURL() -> URL {
		URL.cachesDirectory.appendingPathComponent("\(type(of: self)).sqlite")
	}
}

private extension URL {
	static var cachesDirectory: URL {
		FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}
