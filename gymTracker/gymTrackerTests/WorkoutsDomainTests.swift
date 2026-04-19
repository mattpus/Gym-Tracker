import XCTest
@testable import gymTracker

final class WorkoutsDomainTests: XCTestCase {
	func testStartRoutineCreatesUnfinishedWorkoutWithRoutineSetTypes() {
		let routine = Routine(
			id: UUID(),
			name: "Push",
			exercises: [
				RoutineExercise(
					id: UUID(),
					name: "Bench Press",
					sets: [
						RoutineSet(order: 0, type: .warmup, repetitions: 10, weight: 20),
						RoutineSet(order: 1, type: .main, repetitions: 8, weight: 60),
						RoutineSet(order: 2, type: .backoff, repetitions: 12, weight: 40)
					]
				)
			]
		)
		let routineRepository = RoutineRepositorySpy(storedRoutines: [routine])
		let workoutRepository = WorkoutRepositorySpy()
		let scheduler = ScheduleWorkoutUseCase(repository: workoutRepository)
		let now = Date()
		let sut = StartRoutineUseCase(
			routineRepository: routineRepository,
			workoutScheduler: scheduler,
			currentDate: { now },
			uuid: UUID.init
		)

		let exp = expectation(description: "start routine")
		var received: Workout?
		sut.startRoutine(id: routine.id) { result in
			received = try? result.get()
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(received?.isFinished, false)
		XCTAssertEqual(received?.lastUpdatedAt, now)
		XCTAssertEqual(received?.exercises.first?.sets.map(\.type), [.warmup, .main, .backoff])
	}

	func testFinishWorkoutMarksWorkoutFinished() {
		let workout = Workout(id: UUID(), date: Date(), lastUpdatedAt: Date(), isFinished: false, name: "Legs", exercises: [])
		let repository = WorkoutRepositorySpy(storedWorkouts: [workout])
		let sut = FinishWorkoutUseCase(repository: repository)
		let endDate = Date().addingTimeInterval(120)

		let exp = expectation(description: "finish")
		sut.finish(workoutID: workout.id, at: endDate) { _ in exp.fulfill() }
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(repository.storedWorkouts.first?.isFinished, true)
		XCTAssertEqual(repository.storedWorkouts.first?.lastUpdatedAt, endDate)
	}

	func testDeleteWorkoutHistoryClearsAllWorkouts() {
		let repository = WorkoutRepositorySpy(storedWorkouts: [Workout(date: Date(), name: "A", exercises: [])])
		let sut = DeleteWorkoutHistoryUseCase(repository: repository)

		let exp = expectation(description: "delete")
		sut.deleteAllHistory { result in
			do {
				_ = try result.get()
			} catch {
				XCTFail("Expected delete to succeed, got error: \(error)")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)

		XCTAssertTrue(repository.storedWorkouts.isEmpty)
	}

	func testExportWorkoutHistoryCSVExportsOneRowPerFinishedSet() throws {
		let workout = Workout(
			date: Date(timeIntervalSince1970: 0),
			lastUpdatedAt: Date(timeIntervalSince1970: 0),
			isFinished: true,
			name: "Push",
			exercises: [
				Exercise(name: "Bench", sets: [
					ExerciseSet(order: 0, type: .warmup, repetitions: 12, weight: 20, isCompleted: true),
					ExerciseSet(order: 1, type: .main, repetitions: 8, weight: 60, isCompleted: true)
				])
			]
		)
		let repository = WorkoutRepositorySpy(storedWorkouts: [workout, Workout(date: Date(), lastUpdatedAt: Date(), isFinished: false, name: "Active", exercises: [])])
		let sut = ExportWorkoutHistoryCSVUseCase(repository: repository)

		let csv = try sut.exportCSV()
		let rows = csv.split(separator: "\n")

		XCTAssertEqual(rows.count, 3)
		XCTAssertTrue(rows[0].contains("workout_date"))
		XCTAssertTrue(rows[1].contains("warmup"))
		XCTAssertTrue(rows[2].contains("main"))
		XCTAssertFalse(csv.contains("Active"))
	}

	func testExerciseSetLoggingUpdatePreservesAndWritesSetTypeAndCompletion() {
		let workout = Workout(
			id: UUID(),
			date: Date(),
			lastUpdatedAt: Date(),
			isFinished: false,
			name: "Push",
			exercises: [
				Exercise(
					id: UUID(),
					name: "Bench",
					sets: [ExerciseSet(id: UUID(), order: 0, type: .main, repetitions: nil, weight: nil, isCompleted: false)]
				)
			]
		)
		let repository = WorkoutRepositorySpy(storedWorkouts: [workout])
		let sut = ExerciseSetLoggingUseCase(repository: repository, historyProvider: ExerciseHistoryProviderStub(previous: nil))
		let set = workout.exercises[0].sets[0]

		let exp = expectation(description: "update set")
		var updated: ExerciseSet?
		sut.updateSet(in: workout.id, exerciseID: workout.exercises[0].id, setID: set.id, request: ExerciseSetRequest(type: .superset, repetitions: 10, weight: 40, duration: nil, isCompleted: true)) { result in
			updated = try? result.get().set
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(updated?.type, .superset)
		XCTAssertEqual(updated?.repetitions, 10)
		XCTAssertEqual(updated?.weight, 40)
		XCTAssertEqual(updated?.isCompleted, true)
	}
}
