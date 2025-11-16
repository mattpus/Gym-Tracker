import Foundation

public protocol RoutineBuilding {
	typealias Result = Swift.Result<Void, Swift.Error>
	
	func create(_ routine: Routine, completion: @escaping (Result) -> Void)
}
