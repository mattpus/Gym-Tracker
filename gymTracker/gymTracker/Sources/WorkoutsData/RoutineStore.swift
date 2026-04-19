import Foundation

public protocol RoutineStore {
	func retrieve() throws -> CachedRoutines?
	func deleteCachedRoutines() throws
	func insert(_ routines: [LocalRoutine], timestamp: Date) throws
}

public struct CachedRoutines: Equatable {
	public let routines: [LocalRoutine]
	public let timestamp: Date
	
	public init(routines: [LocalRoutine], timestamp: Date) {
		self.routines = routines
		self.timestamp = timestamp
	}
}
