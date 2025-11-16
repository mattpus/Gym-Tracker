import XCTest
@testable import WorkoutsDomain

@MainActor
final class RemoveWorkoutExerciseUseCaseTests: XCTestCase {
	func test_removeExercise_whenWorkoutMissing_fails() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])

		expect(sut, toCompleteWith: .failure(RemoveWorkoutExerciseUseCase.Error.workoutNotFound))
	}

	func test_removeExercise_whenExerciseMissing_fails() {
		let workout = makeWorkout(exerciseIDs: [UUID()])
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		expect(sut, toCompleteWith: .failure(RemoveWorkoutExerciseUseCase.Error.exerciseNotFound), workout: workout, exerciseID: UUID())
	}

	func test_removeExercise_whenLastExercise_fails() {
		let exerciseID = UUID()
		let workout = makeWorkout(exerciseIDs: [exerciseID])
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		expect(sut, toCompleteWith: .failure(RemoveWorkoutExerciseUseCase.Error.lastExerciseRemovalNotAllowed), workout: workout, exerciseID: exerciseID)
	}

	func test_removeExercise_updatesWorkoutAndSaves() {
		let ids = [UUID(), UUID()]
		let workout = makeWorkout(exerciseIDs: ids)
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		let exp = expectation(description: "Wait for completion")
		sut.removeExercise(in: workout.id, exerciseID: ids.first!) { result in
			if case let .success(updated) = result {
				XCTAssertEqual(updated.exercises.count, 1)
				XCTAssertEqual(updated.exercises.first?.id, ids.last)
			} else {
				XCTFail("Expected success")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoveWorkoutExerciseUseCase, WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = RemoveWorkoutExerciseUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}

	private func makeWorkout(exerciseIDs: [UUID]) -> Workout {
		let exercises = exerciseIDs.map { Exercise(id: $0, name: "Exercise\($0)", sets: []) }
		return Workout(date: Date(), name: "Workout", exercises: exercises)
	}

	private func expect(
		_ sut: RemoveWorkoutExerciseUseCase,
		toCompleteWith expectedResult: WorkoutExerciseRemoving.Result,
		workout: Workout = Workout(date: Date(), name: "", exercises: []),
		exerciseID: UUID = UUID()
	) {
		let exp = expectation(description: "Wait for completion")
		sut.removeExercise(in: workout.id, exerciseID: exerciseID) { result in
			if case let .failure(received as RemoveWorkoutExerciseUseCase.Error) = result,
				case let .failure(expected as RemoveWorkoutExerciseUseCase.Error) = expectedResult {
				XCTAssertEqual(received, expected)
			} else if case .success = expectedResult, case .success = result {
				// success handled in callers
			} else {
				XCTFail("Expected \(expectedResult), got \(result)")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
}
