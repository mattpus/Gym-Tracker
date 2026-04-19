import Foundation

public final class LoadExerciseLibraryUseCase: ExerciseLibraryLoading {
    private let repository: ExerciseLibraryRepository
    
    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    public func load() throws -> [LibraryExercise] {
        try repository.loadAll()
    }
}
