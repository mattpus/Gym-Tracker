import Foundation
import ExerciseLibraryDomain

public protocol ExerciseLibraryStore {
    func loadAll() throws -> [LocalLibraryExercise]
    func save(_ exercises: [LocalLibraryExercise]) throws
    func delete(_ exerciseId: UUID) throws
    func hasSeedData() throws -> Bool
}
