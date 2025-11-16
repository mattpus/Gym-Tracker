import XCTest
@testable import WorkoutsDomain

@MainActor
final class ReplaceWorkoutExerciseUseCaseTests: XCTestCase {
	func test_replaceExercise_whenWorkoutMissing_fails() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])

		expect(sut, toCompleteWith: .failure(ReplaceWorkoutExerciseUseCase.Error.workoutNotFound), whenReplacing: UUID())
	}

	func test_replaceExercise_whenExerciseMissing_fails() {
		let workout = makeWorkout(id: UUID())
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		expect(sut, toCompleteWith: .failure(ReplaceWorkoutExerciseUseCase.Error.exerciseNotFound), whenReplacing: UUID(), in: workout)
	}

	func test_replaceExercise_updatesWorkoutAndClearsSets() {
		let exerciseID = UUID()
		let workout = makeWorkout(id: UUID(), exerciseID: exerciseID)
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		let libraryItem = ExerciseLibraryItem(id: UUID(), name: "Row", primaryMuscle: "Back")

		let exp = expectation(description: "Wait for completion")
		sut.replaceExercise(in: workout.id, existingExerciseID: exerciseID, with: libraryItem) { result in
			if case let .success(updated) = result {
				XCTAssertEqual(updated.exercises.first?.name, "Row")
				XCTAssertTrue(updated.exercises.first?.sets.isEmpty == true)
			} else {
				XCTFail("Expected success")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ReplaceWorkoutExerciseUseCase, WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = ReplaceWorkoutExerciseUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}

	private func makeWorkout(id: UUID, exerciseID: UUID = UUID()) -> Workout {
		let exercise = Exercise(id: exerciseID, name: "Bench", sets: [ExerciseSet(order: 0, repetitions: 10, weight: 135)])
		return Workout(id: id, date: Date(), name: "Push", exercises: [exercise])
	}

	private func expect(
		_ sut: ReplaceWorkoutExerciseUseCase,
		toCompleteWith expectedResult: WorkoutExerciseReplacing.Result,
		whenReplacing exerciseID: UUID,
		in workout: Workout = Workout(date: Date(), name: "", exercises: [])
	) {
		let exp = expectation(description: "Wait for completion")
		sut.replaceExercise(in: workout.id, existingExerciseID: exerciseID, with: ExerciseLibraryItem(id: UUID(), name: "Row", primaryMuscle: nil)) { result in
			if case let .failure(receivedError as ReplaceWorkoutExerciseUseCase.Error) = result,
				case let .failure(expectedError as ReplaceWorkoutExerciseUseCase.Error) = expectedResult {
				XCTAssertEqual(receivedError, expectedError)
			} else {
				XCTFail("Expected \(expectedResult), got \(result)")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
}
