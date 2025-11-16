import Foundation

public protocol RoutineReordering {
	typealias Result = Swift.Result<Routine, Error>
	
	func reorderExercises(in routine: Routine, from sourceIndex: Int, to destinationIndex: Int) -> Result
}
