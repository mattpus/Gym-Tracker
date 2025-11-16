import Foundation
import WorkoutsDomain
@testable import WorkoutsData

func makeWorkout(
	id: UUID = UUID(),
	date: Date = Date(),
	name: String = "Workout",
	notes: String? = "Notes"
) -> (model: Workout, local: LocalWorkout) {
	let sets = [
		ExerciseSet(id: UUID(), order: 0, repetitions: 10, weight: 45, duration: 60)
	]
	let exercises = [
		Exercise(id: UUID(), name: "Bench Press", notes: "Warmup", sets: sets)
	]
	let model = Workout(id: id, date: date, name: name, notes: notes, exercises: exercises)
	let local = [model].toLocal().first!
	return (model, local)
}

func anyError() -> NSError {
	NSError(domain: "test", code: 0)
}

func uniqueWorkoutsCache(timestamp: Date = Date()) -> (workouts: [LocalWorkout], timestamp: Date) {
	let workout = makeWorkout()
	return ([workout.local], timestamp)
}
