import XCTest
@testable import WorkoutsDomain

@MainActor
final class FinishWorkoutUseCaseTests: XCTestCase {
	
	func test_finish_requestsLoadAndSave() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		
		sut.finish(workoutID: workout.id, at: workout.date.addingTimeInterval(60)) { _ in }
		
		XCTAssertEqual(repository.messages, [.load, .save([workout])])
	}
	
	func test_finish_deliversSummaryStats() {
		let sets = [
			ExerciseSet(order: 0, repetitions: 10, weight: 50, duration: nil),
			ExerciseSet(order: 1, repetitions: 8, weight: 60, duration: nil)
		]
		let workout = Workout(date: Date(), name: "Push", exercises: [
			Exercise(name: "Bench", sets: sets)
		])
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		let finishDate = workout.date.addingTimeInterval(3600)
		
		var receivedSummary: WorkoutSummary?
		sut.finish(workoutID: workout.id, at: finishDate) { result in
			receivedSummary = try? result.get()
		}
		
		XCTAssertEqual(receivedSummary?.stats.totalSets, 2)
		XCTAssertEqual(receivedSummary?.stats.totalVolume, 10 * 50 + 8 * 60)
		XCTAssertEqual(receivedSummary?.stats.duration, finishDate.timeIntervalSince(workout.date))
	}
	
	func test_finish_deliversErrorWhenWorkoutMissing() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])
		
		var receivedError: Error?
		sut.finish(workoutID: UUID(), at: Date()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}
		
		XCTAssertNotNil(receivedError)
	}
	
	func test_discard_removesWorkoutFromRepository() {
		let workout = makeWorkout()
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([workout])
		
		sut.discard(workoutID: workout.id) { _ in }
		
		XCTAssertEqual(repository.messages, [.load, .save([])])
	}
	
	func test_discard_deliversErrorWhenWorkoutMissing() {
		let (sut, repository) = makeSUT()
		repository.loadResult = .success([])
		
		var receivedError: Error?
		sut.discard(workoutID: UUID()) { result in
			if case let .failure(error) = result {
				receivedError = error
			}
		}
		
		XCTAssertNotNil(receivedError)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FinishWorkoutUseCase, repository: WorkoutRepositorySpy) {
		let repository = WorkoutRepositorySpy()
		let sut = FinishWorkoutUseCase(repository: repository)
		trackForMemoryLeaks(repository, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, repository)
	}
	
	private func makeWorkout(id: UUID = UUID(), date: Date = Date()) -> Workout {
		Workout(id: id, date: date, name: "Workout", exercises: [
			Exercise(name: "Bench", sets: [])
		])
	}
}
