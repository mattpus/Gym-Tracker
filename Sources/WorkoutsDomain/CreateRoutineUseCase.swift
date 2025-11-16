import Foundation

public final class CreateRoutineUseCase: RoutineBuilding {
	public enum Error: Swift.Error {
		case emptyName
		case emptyExercises
	}
	
	private let repository: RoutineRepository
	
	public init(repository: RoutineRepository) {
		self.repository = repository
	}
	
	public func create(_ routine: Routine, completion: @escaping (RoutineBuilding.Result) -> Void) {
		completion(create(routine))
	}
	
	private func create(_ routine: Routine) -> RoutineBuilding.Result {
		do {
			try validate(routine)
			var routines = try repository.loadRoutines()
			routines.removeAll { $0.id == routine.id }
			routines.append(routine)
			try repository.save(routines)
			return .success(())
		} catch {
			return .failure(error)
		}
	}
	
	private func validate(_ routine: Routine) throws {
		if routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			throw Error.emptyName
		}
		
		if routine.exercises.isEmpty {
			throw Error.emptyExercises
		}
	}
}

extension CreateRoutineUseCase.Error: Equatable {}
