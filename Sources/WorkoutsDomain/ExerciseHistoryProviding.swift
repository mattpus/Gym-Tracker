import Foundation

public protocol ExerciseHistoryProviding {
	func previousSet(for exerciseID: UUID, before date: Date) throws -> ExerciseSet?
}
