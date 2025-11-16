import Foundation

public protocol RoutinesLoading {
	typealias Result = Swift.Result<[Routine], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
