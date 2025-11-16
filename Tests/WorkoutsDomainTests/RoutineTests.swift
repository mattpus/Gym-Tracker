import XCTest
@testable import WorkoutsDomain

final class RoutineTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		let exercises = [makeExercise()]
		
		let sut = Routine(id: id, name: "Push", notes: "Upper body", exercises: exercises)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.name, "Push")
		XCTAssertEqual(sut.notes, "Upper body")
		XCTAssertEqual(sut.exercises, exercises)
	}
	
	func test_isEmpty_reflectsExercises() {
		XCTAssertTrue(Routine(name: "Empty", exercises: []).isEmpty)
		XCTAssertFalse(Routine(name: "Full", exercises: [makeExercise()]).isEmpty)
	}
	
	private func makeExercise() -> RoutineExercise {
		RoutineExercise(name: "Bench Press", sets: [RoutineSet(order: 0)])
	}
}

final class RoutineExerciseTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		let sets = [RoutineSet(order: 0)]
		
		let sut = RoutineExercise(id: id, name: "Bench", notes: "Flat", sets: sets)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.name, "Bench")
		XCTAssertEqual(sut.notes, "Flat")
		XCTAssertEqual(sut.sets, sets)
	}
	
	func test_hasConfiguredSets_reflectsSets() {
		XCTAssertFalse(RoutineExercise(name: "Bench", sets: []).hasConfiguredSets)
		XCTAssertTrue(RoutineExercise(name: "Bench", sets: [RoutineSet(order: 0)]).hasConfiguredSets)
	}
}

final class RoutineSetTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		
		let sut = RoutineSet(
			id: id,
			order: 0,
			repetitions: 10,
			weight: 135,
			duration: 60
		)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.order, 0)
		XCTAssertEqual(sut.repetitions, 10)
		XCTAssertEqual(sut.weight, 135)
		XCTAssertEqual(sut.duration, 60)
	}
	
	func test_flags_reflectProperties() {
		let weighted = RoutineSet(order: 0, weight: 45)
		XCTAssertTrue(weighted.isWeighted)
		XCTAssertFalse(weighted.isTimed)
		
		let timed = RoutineSet(order: 0, duration: 30)
		XCTAssertFalse(timed.isWeighted)
		XCTAssertTrue(timed.isTimed)
		
		let bodyweight = RoutineSet(order: 0)
		XCTAssertFalse(bodyweight.isWeighted)
		XCTAssertFalse(bodyweight.isTimed)
	}
}
