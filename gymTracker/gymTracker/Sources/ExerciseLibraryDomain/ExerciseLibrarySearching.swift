import Foundation

public protocol ExerciseLibrarySearching {
    func search(query: String) throws -> [LibraryExercise]
    func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise]
}
