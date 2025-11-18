import XCTest
import WorkoutsDomain
@testable import WorkoutsData

final class LocalWorkoutMapperTests: XCTestCase {
	func test_toLocal_encodesDomainWorkouts() {
		let workout = makeWorkout()
		
		let local = [workout.model].toLocal()
		
		XCTAssertEqual(local, [workout.local])
	}
	
	func test_toModels_decodesLocalWorkouts() {
		let workout = makeWorkout()
		
		let models = [workout.local].toModels()
		
		XCTAssertEqual(models, [workout.model])
	}

	func test_toLocal_preservesSupersetMetadataAndNotes() {
		let supersetID = UUID()
		let set = ExerciseSet(order: 0, repetitions: 8, weight: 100, duration: 45)
		let exercise = Exercise(
			id: UUID(),
			name: "Bench",
			notes: "Keep elbows in",
			sets: [set],
			supersetID: supersetID,
			supersetOrder: 1
		)
		let workout = Workout(date: Date(), name: "Push", notes: "AM", exercises: [exercise])

		let local = [workout].toLocal().first
		let localExercise = local?.exercises.first

		XCTAssertEqual(localExercise?.supersetID, supersetID)
		XCTAssertEqual(localExercise?.supersetOrder, 1)
		XCTAssertEqual(localExercise?.notes, "Keep elbows in")
		XCTAssertEqual(localExercise?.sets.first?.duration, 45)
		XCTAssertEqual(local?.notes, "AM")
	}

	func test_toModels_preservesSupersetMetadataAndSetMetrics() {
		let supersetID = UUID()
		let localSet = LocalExerciseSet(
			id: UUID(),
			order: 0,
			repetitions: 12,
			weight: 80,
			duration: 30
		)
		let localExercise = LocalExercise(
			id: UUID(),
			name: "Rows",
			notes: "Pause",
			sets: [localSet],
			supersetID: supersetID,
			supersetOrder: 0
		)
		let localWorkout = LocalWorkout(
			id: UUID(),
			date: Date(),
			name: "Back",
			notes: "PM",
			exercises: [localExercise]
		)

		let model = [localWorkout].toModels().first
		let exercise = model?.exercises.first
		let set = exercise?.sets.first

		XCTAssertEqual(exercise?.supersetID, supersetID)
		XCTAssertEqual(exercise?.supersetOrder, 0)
		XCTAssertEqual(exercise?.notes, "Pause")
		XCTAssertEqual(set?.repetitions, 12)
		XCTAssertEqual(set?.weight, 80)
		XCTAssertEqual(set?.duration, 30)
		XCTAssertEqual(model?.notes, "PM")
	}
}
