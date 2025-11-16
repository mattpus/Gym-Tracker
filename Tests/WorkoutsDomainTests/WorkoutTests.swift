import XCTest
@testable import WorkoutsDomain

final class WorkoutTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		let date = Date()
		let exercises = [
			Exercise(name: "Bench", sets: [ExerciseSet(order: 0)])
		]
		
		let sut = Workout(
			id: id,
			date: date,
			name: "Push Day",
			notes: "Felt strong",
			exercises: exercises
		)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.date, date)
		XCTAssertEqual(sut.name, "Push Day")
		XCTAssertEqual(sut.notes, "Felt strong")
		XCTAssertEqual(sut.exercises, exercises)
	}
	
	func test_isEmpty_reflectsExerciseCollection() {
		XCTAssertTrue(Workout(date: Date(), name: "Rest", exercises: []).isEmpty)
		XCTAssertFalse(
			Workout(date: Date(), name: "Push", exercises: [Exercise(name: "Bench", sets: [ExerciseSet(order: 0)])]).isEmpty
		)
	}
}
