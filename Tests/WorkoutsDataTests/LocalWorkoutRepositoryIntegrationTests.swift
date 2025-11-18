import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class LocalWorkoutRepositoryIntegrationTests: XCTestCase {
	
	override func setUp() async throws {
		try await super.setUp()
		
		deleteStoreArtifacts()
	}
	
	override func tearDown() async throws {
		try await super.tearDown()
		
		deleteStoreArtifacts()
	}
	
	func test_load_deliversNoWorkoutsOnEmptyStore() throws {
		let sut = try makeSUT()
		
		let loaded = try sut.loadWorkouts()
		
		XCTAssertEqual(loaded, [])
	}
	
	func test_load_deliversWorkoutsSavedOnASeparateInstance() throws {
		let workouts = [uniqueWorkout(), uniqueWorkout()]
		let saveSUT = try makeSUT()
		let loadSUT = try makeSUT()
		
		try saveSUT.save(workouts)
		let loaded = try loadSUT.loadWorkouts()
		
		XCTAssertEqual(loaded, workouts)
	}
	
	func test_save_overridesWorkoutsSavedOnASeparateInstance() throws {
		let firstSaveSUT = try makeSUT()
		let lastSaveSUT = try makeSUT()
		let loadSUT = try makeSUT()
		let firstWorkouts = [uniqueWorkout(name: "First")]
		let latestWorkouts = [uniqueWorkout(name: "Latest")]
		
		try firstSaveSUT.save(firstWorkouts)
		try lastSaveSUT.save(latestWorkouts)
		let loaded = try loadSUT.loadWorkouts()
		
		XCTAssertEqual(loaded, latestWorkouts)
	}

	func test_saveAndLoad_preservesSupersetNotesAndSetMetrics() throws {
		let workout = supersetWorkout()
		let saveSUT = try makeSUT()
		let loadSUT = try makeSUT()

		try saveSUT.save([workout])
		let loaded = try loadSUT.loadWorkouts()

		XCTAssertEqual(loaded, [workout])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) throws -> LocalWorkoutRepository {
		let store = try CoreDataWorkoutStore(storeURL: testSpecificStoreURL(), contextQueue: .main)
		let sut = LocalWorkoutRepository(store: store, currentDate: Date.init)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func uniqueWorkout(name: String = "Workout") -> Workout {
		let sets = [
			ExerciseSet(order: 0, repetitions: 10, weight: 50, duration: 60)
		]
		let exercises = [
			Exercise(name: "Bench", notes: "Incline", sets: sets)
		]
		return Workout(
			date: Date(),
			name: name,
			notes: "Notes",
			exercises: exercises
		)
	}

	private func supersetWorkout() -> Workout {
		let supersetID = UUID()
		let sets = [
			ExerciseSet(order: 0, repetitions: 12, weight: 40, duration: 30),
			ExerciseSet(order: 1, repetitions: 12, weight: 40, duration: 30)
		]
		let exercises = [
			Exercise(id: UUID(), name: "Curl", notes: "Superset A", sets: sets, supersetID: supersetID, supersetOrder: 0),
			Exercise(id: UUID(), name: "Tricep Pushdown", notes: "Superset B", sets: sets, supersetID: supersetID, supersetOrder: 1)
		]
		return Workout(
			date: Date(),
			name: "Arms",
			notes: "Superset session",
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
