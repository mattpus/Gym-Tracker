import Foundation

public protocol RoutineRepository {
	func save(_ routines: [Routine]) throws
	func loadRoutines() throws -> [Routine]
}
