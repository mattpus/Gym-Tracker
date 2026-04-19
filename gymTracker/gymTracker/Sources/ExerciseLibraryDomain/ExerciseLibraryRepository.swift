import Foundation

public protocol ExerciseLibraryRepository {
    func loadAll() throws -> [LibraryExercise]
    func save(_ exercise: LibraryExercise) throws
    func delete(_ exerciseId: UUID) throws
    func search(query: String) throws -> [LibraryExercise]
    func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise]
    func exercise(byId id: UUID) throws -> LibraryExercise?
}
