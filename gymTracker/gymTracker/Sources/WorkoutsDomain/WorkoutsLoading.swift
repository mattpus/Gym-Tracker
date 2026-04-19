import Foundation

public protocol WorkoutsLoading {
	typealias Result = Swift.Result<[Workout], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
