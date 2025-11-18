import XCTest
@testable import WorkoutsDomain

@MainActor
final class LinkExercisesToSupersetUseCaseTests: XCTestCase {
	func test_linkFailsWhenWorkoutMissing() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])
		expect(sut, toCompleteWith: .failure(LinkExercisesToSupersetUseCase.Error.workoutNotFound))
	}

	func test_linkFailsWhenInsufficientExercises() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([makeWorkout()])
		expect(sut, toCompleteWith: .failure(LinkExercisesToSupersetUseCase.Error.insufficientExercises), exerciseIDs: [UUID()])
	}

	func test_linkFailsWhenExerciseMissing() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		expect(sut, toCompleteWith: .failure(LinkExercisesToSupersetUseCase.Error.exerciseNotFound), workout: workout, exerciseIDs: [UUID(), UUID()])
	}

	func test_linkAssignsSupersetIDAndOrder() {
		let ids = [UUID(), UUID(), UUID()]
		let workout = makeWorkout(exerciseIDs: ids)
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		let exp = expectation(description: "wait")
		sut.linkExercises(in: workout.id, exerciseIDs: [ids[0], ids[2]], supersetID: nil) { result in
			if case let .success(updated) = result {
				let supersetID = updated.exercises.first(where: { $0.id == ids[0] })?.supersetID
				XCTAssertNotNil(supersetID)
				XCTAssertEqual(updated.exercises.first(where: { $0.id == ids[0] })?.supersetOrder, 0)
				XCTAssertEqual(updated.exercises.first(where: { $0.id == ids[2] })?.supersetOrder, 1)
			} else {
				XCTFail("Expected success")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LinkExercisesToSupersetUseCase, WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = LinkExercisesToSupersetUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}

	private func makeWorkout(exerciseIDs: [UUID] = [UUID(), UUID()]) -> Workout {
		let exercises = exerciseIDs.map { Exercise(id: $0, name: "Exercise\($0)", sets: []) }
		return Workout(date: Date(), name: "Workout", exercises: exercises)
	}

	private func expect(
		_ sut: LinkExercisesToSupersetUseCase,
		toCompleteWith expected: WorkoutSupersetLinking.Result,
		workout: Workout = Workout(date: Date(), name: "", exercises: []),
		exerciseIDs: [UUID] = [UUID(), UUID()]
	) {
		let exp = expectation(description: "wait")
		sut.linkExercises(in: workout.id, exerciseIDs: exerciseIDs, supersetID: nil) { result in
			if case let .failure(received as LinkExercisesToSupersetUseCase.Error) = result,
				case let .failure(expectedError as LinkExercisesToSupersetUseCase.Error) = expected {
				XCTAssertEqual(received, expectedError)
			} else if case .success = expected, case .success = result {
				// handled elsewhere
			} else {
				XCTFail("Expected \(expected), got \(result)")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
}
