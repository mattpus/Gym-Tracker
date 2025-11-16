import XCTest
@testable import WorkoutsDomain

@MainActor
final class ReorderWorkoutExercisesUseCaseTests: XCTestCase {
	func test_reorderNonexistentWorkout_fails() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])

		let exp = expectation(description: "Wait for completion")
		sut.reorderExercises(in: UUID(), from: 0, to: 1) { result in
			if case let .failure(error as ReorderWorkoutExercisesUseCase.Error) = result {
				XCTAssertEqual(error, .workoutNotFound)
			} else {
				XCTFail("Expected workoutNotFound")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_reorderWithInvalidIndexes_fails() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		let exp = expectation(description: "Wait for completion")
		sut.reorderExercises(in: workout.id, from: 5, to: 0) { result in
			if case let .failure(error as ReorderWorkoutExercisesUseCase.Error) = result {
				XCTAssertEqual(error, .invalidIndexes)
			} else {
				XCTFail("Expected invalidIndexes")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_reorderUpdatesWorkoutAndSaves() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])

		let exp = expectation(description: "Wait for completion")
		sut.reorderExercises(in: workout.id, from: 0, to: 1) { result in
			if case let .success(updated) = result {
				XCTAssertEqual(updated.exercises.first?.name, workout.exercises.last?.name)
			} else {
				XCTFail("Expected success")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(repository.messages.last?.savedWorkouts?.first?.exercises.first?.name, workout.exercises.last?.name)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ReorderWorkoutExercisesUseCase, WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = ReorderWorkoutExercisesUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}

	private func makeWorkout() -> Workout {
		let exercises = [
			Exercise(name: "Bench", sets: []),
			Exercise(name: "Deadlift", sets: [])
		]
		return Workout(date: Date(), name: "Push", exercises: exercises)
	}
}
