import XCTest
import WorkoutsDomain
@testable import WorkoutsData

@MainActor
final class LocalExerciseHistoryProviderTests: XCTestCase {

	func test_previousSet_returnsNilWhenCacheEmpty() throws {
		let store = WorkoutStoreStub(retrieveResult: .success(nil))
		let sut = LocalExerciseHistoryProvider(store: store)

		XCTAssertNil(try sut.previousSet(for: UUID(), before: Date()))
	}

	func test_previousSet_returnsNilWhenExerciseNotFound() throws {
		let workout = makeWorkout(exerciseID: UUID(), date: Date().addingTimeInterval(-3600))
		let store = WorkoutStoreStub(retrieveResult: .success(.init(workouts: [workout.local], timestamp: Date())))
		let sut = LocalExerciseHistoryProvider(store: store)

		let result = try sut.previousSet(for: UUID(), before: Date())

		XCTAssertNil(result)
	}

	func test_previousSet_returnsLatestSetBeforeProvidedDate() throws {
		let exerciseID = UUID()
		let earlierSet = ExerciseSet(order: 0, repetitions: 8, weight: 60, duration: nil)
		let laterSet = ExerciseSet(order: 0, repetitions: 10, weight: 65, duration: nil)
		let earlier = makeWorkout(exerciseID: exerciseID, date: Date().addingTimeInterval(-7200), set: earlierSet)
		let later = makeWorkout(exerciseID: exerciseID, date: Date().addingTimeInterval(-3600), set: laterSet)
		let cache = CachedWorkouts(workouts: [later.local, earlier.local], timestamp: Date())
		let store = WorkoutStoreStub(retrieveResult: .success(cache))
		let sut = LocalExerciseHistoryProvider(store: store)

		let result = try sut.previousSet(for: exerciseID, before: later.model.date)

		XCTAssertEqual(result, earlierSet)
	}

	func test_previousSet_ignoresWorkoutsOnOrAfterProvidedDate() throws {
		let exerciseID = UUID()
		let sameDateSet = ExerciseSet(order: 0, repetitions: 12, weight: 70, duration: nil)
		let current = makeWorkout(exerciseID: exerciseID, date: Date(), set: sameDateSet)
		let store = WorkoutStoreStub(retrieveResult: .success(.init(workouts: [current.local], timestamp: Date())))
		let sut = LocalExerciseHistoryProvider(store: store)

		let result = try sut.previousSet(for: exerciseID, before: current.model.date)

		XCTAssertNil(result)
	}

	// MARK: - Helpers

	private func makeWorkout(exerciseID: UUID, date: Date, set: ExerciseSet? = nil) -> (model: Workout, local: LocalWorkout) {
		let exercise = Exercise(id: exerciseID, name: "Bench", notes: nil, sets: [set ?? ExerciseSet(order: 0, repetitions: 5, weight: 50, duration: nil)])
		let workout = Workout(id: UUID(), date: date, name: "Workout", notes: nil, exercises: [exercise])
		let local = [workout].toLocal().first!
		return (workout, local)
	}
}

private final class WorkoutStoreStub: WorkoutStore {
	private let retrieveResult: Result<CachedWorkouts?, Error>

	init(retrieveResult: Result<CachedWorkouts?, Error>) {
		self.retrieveResult = retrieveResult
	}

	func insert(_ workouts: [LocalWorkout], timestamp: Date) throws {
		fatalError("Not implemented")
	}

	func retrieve() throws -> CachedWorkouts? {
		try retrieveResult.get()
	}

	func deleteCachedWorkouts() throws {
		fatalError("Not implemented")
	}
}
