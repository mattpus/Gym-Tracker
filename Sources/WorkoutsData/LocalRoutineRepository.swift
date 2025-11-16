import Foundation
import WorkoutsDomain

public final class LocalRoutineRepository: RoutineRepository {
	private let store: RoutineStore
	private let currentDate: () -> Date
	
	public init(store: RoutineStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	public func loadRoutines() throws -> [Routine] {
		if let cache = try store.retrieve() {
			return cache.routines.toRoutineModels()
		}
		return []
	}
	
	public func save(_ routines: [Routine]) throws {
		try store.deleteCachedRoutines()
		try store.insert(routines.toLocalRoutines(), timestamp: currentDate())
	}
}
