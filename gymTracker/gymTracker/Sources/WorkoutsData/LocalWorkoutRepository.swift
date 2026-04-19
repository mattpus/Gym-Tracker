import Foundation

public final class LocalWorkoutRepository: WorkoutRepository {
	private let store: WorkoutStore
	private let currentDate: () -> Date
	
	public init(store: WorkoutStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func loadWorkouts() throws -> [Workout] {
		if let cache = try store.retrieve() {
			return cache.workouts.toModels()
		}
		return []
	}
	
	public func save(_ workouts: [Workout]) throws {
		try store.deleteCachedWorkouts()
		try store.insert(workouts.toLocal(), timestamp: currentDate())
	}

	public func makeExerciseSetLoggingUseCase() -> ExerciseSetLoggingUseCase {
		let historyProvider = LocalExerciseHistoryProvider(store: store)
		return ExerciseSetLoggingUseCase(repository: self, historyProvider: historyProvider)
	}
}
