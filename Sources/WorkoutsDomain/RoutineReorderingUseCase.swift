import Foundation

public final class RoutineReorderingUseCase: RoutineReordering {
	public enum Error: Swift.Error, Equatable {
		case invalidIndexes
	}
	
	public init() {}
	
	public func reorderExercises(in routine: Routine, from sourceIndex: Int, to destinationIndex: Int) -> RoutineReordering.Result {
		guard routine.exercises.indices.contains(sourceIndex),
			  routine.exercises.indices.contains(destinationIndex) else {
			return .failure(Error.invalidIndexes)
		}
		
		var exercises = routine.exercises
		let exercise = exercises.remove(at: sourceIndex)
		exercises.insert(exercise, at: destinationIndex)
		
		let reordered = Routine(
			id: routine.id,
			name: routine.name,
			notes: routine.notes,
			exercises: exercises
		)
		
		return .success(reordered)
	}
}
