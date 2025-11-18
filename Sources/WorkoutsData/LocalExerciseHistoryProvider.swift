import Foundation
import WorkoutsDomain

public final class LocalExerciseHistoryProvider: ExerciseHistoryProviding {
	private let store: WorkoutStore

	public init(store: WorkoutStore) {
		self.store = store
	}

	public func previousSet(for exerciseID: UUID, before date: Date) throws -> ExerciseSet? {
		guard let cache = try store.retrieve() else {
			return nil
		}

		return cache.workouts
			.toModels()
			.filter { $0.date < date }
			.sorted { $0.date > $1.date }
			.compactMap { workout in
				workout.exercises.first(where: { $0.id == exerciseID })?.sets.last
			}
			.first
	}
}
