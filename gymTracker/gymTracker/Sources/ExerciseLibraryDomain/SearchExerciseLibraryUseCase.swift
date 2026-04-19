import Foundation

public final class SearchExerciseLibraryUseCase: ExerciseLibrarySearching {
    private let repository: ExerciseLibraryRepository
    
    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    public func search(query: String) throws -> [LibraryExercise] {
        try repository.search(query: query)
    }
    
    public func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise] {
        try repository.exercises(for: muscleGroup)
    }
}
