import XCTest
@testable import WorkoutsDomain

@MainActor
final class UpdateExerciseNotesUseCaseTests: XCTestCase {

	func test_updateNotes_requestsLoadAndSave() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		repository.loadResult = .success([workout])

		updateNotes(sut, workoutID: workout.id, exerciseID: workout.exercises[0].id, notes: "Tempo")

		XCTAssertEqual(repository.messages.count, 2)
		XCTAssertEqual(repository.messages.first, .load)
		XCTAssertEqual(repository.messages.last?.savedWorkouts?.count, 1)
	}

	func test_updateNotes_updatesExerciseNotes() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		repository.loadResult = .success([workout])

		var receivedWorkout: Workout?
		updateNotes(sut, workoutID: workout.id, exerciseID: workout.exercises[0].id, notes: "Slow eccentric") { result in
			receivedWorkout = try? result.get()
		}

		XCTAssertEqual(receivedWorkout?.exercises.first?.notes, "Slow eccentric")
	}

	func test_updateNotes_failsWhenWorkoutMissing() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])

		var receivedError: Swift.Error?
		updateNotes(sut, workoutID: UUID(), exerciseID: UUID(), notes: "Test") { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}

		XCTAssertNotNil(receivedError)
	}

	func test_updateNotes_failsWhenExerciseMissing() {
		let (sut, repository) = makeSUT()
		let workout = makeWorkout()
		repository.loadResult = .success([workout])

		var receivedError: Swift.Error?
		updateNotes(sut, workoutID: workout.id, exerciseID: UUID(), notes: "Test") { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}

		XCTAssertNotNil(receivedError)
	}

	// MARK: - Helpers

	private func updateNotes(
		_ sut: UpdateExerciseNotesUseCase,
		workoutID: UUID,
		exerciseID: UUID,
		notes: String?,
		completion: ((ExerciseNotesUpdating.Result) -> Void)? = nil
	) {
		sut.updateNotes(in: workoutID, exerciseID: exerciseID, notes: notes) { result in
			completion?(result)
		}
	}

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: UpdateExerciseNotesUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = UpdateExerciseNotesUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}

	private func makeWorkout() -> Workout {
		let exercise = Exercise(name: "Bench", sets: [])
		return Workout(date: Date(), name: "Workout", exercises: [exercise])
	}
}
