import Foundation

public protocol ExerciseLibraryLoading {
    func load() throws -> [LibraryExercise]
}
