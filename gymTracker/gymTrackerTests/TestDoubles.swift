import Foundation
@testable import gymTracker

final class WorkoutRepositorySpy: WorkoutRepository {
	var storedWorkouts: [Workout]
	var saveCalls: [[Workout]] = []

	init(storedWorkouts: [Workout] = []) {
		self.storedWorkouts = storedWorkouts
	}

	func save(_ workouts: [Workout]) throws {
		storedWorkouts = workouts
		saveCalls.append(workouts)
	}

	func loadWorkouts() throws -> [Workout] {
		storedWorkouts
	}
}

final class RoutineRepositorySpy: RoutineRepository {
	var storedRoutines: [Routine]

	init(storedRoutines: [Routine] = []) {
		self.storedRoutines = storedRoutines
	}

	func save(_ routines: [Routine]) throws {
		storedRoutines = routines
	}

	func loadRoutines() throws -> [Routine] {
		storedRoutines
	}
}

struct ExerciseHistoryProviderStub: ExerciseHistoryProviding {
	var previous: ExerciseSet?

	func previousSet(for exerciseID: UUID, before date: Date) throws -> ExerciseSet? {
		previous
	}
}

final class ExerciseLibraryRepositorySpy: ExerciseLibraryRepository {
	var storedExercises: [LibraryExercise]

	init(storedExercises: [LibraryExercise] = []) {
		self.storedExercises = storedExercises
	}

	func loadAll() throws -> [LibraryExercise] {
		storedExercises
	}

	func save(_ exercise: LibraryExercise) throws {
		if let index = storedExercises.firstIndex(where: { $0.id == exercise.id }) {
			storedExercises[index] = exercise
		} else {
			storedExercises.append(exercise)
		}
	}

	func delete(_ exerciseId: UUID) throws {
		storedExercises.removeAll { $0.id == exerciseId }
	}

	func search(query: String) throws -> [LibraryExercise] {
		storedExercises.filter { $0.name.localizedCaseInsensitiveContains(query) }
	}

	func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise] {
		storedExercises.filter { $0.primaryMuscleGroup == muscleGroup || $0.secondaryMuscleGroups.contains(muscleGroup) }
	}

	func exercise(byId id: UUID) throws -> LibraryExercise? {
		storedExercises.first { $0.id == id }
	}
}
