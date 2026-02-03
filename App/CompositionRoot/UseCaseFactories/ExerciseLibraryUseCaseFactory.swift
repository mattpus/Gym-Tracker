import Foundation
import ExerciseLibraryDomain

/// Factory for creating ExerciseLibrary-related use cases
@MainActor
final class ExerciseLibraryUseCaseFactory: Sendable {
    private let repository: ExerciseLibraryRepository
    
    init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    func makeLoadExerciseLibraryUseCase() -> ExerciseLibraryLoading {
        LoadExerciseLibraryUseCase(repository: repository)
    }
    
    func makeSearchExerciseLibraryUseCase() -> ExerciseLibrarySearching {
        SearchExerciseLibraryUseCase(repository: repository)
    }
    
    func makeAddCustomExerciseUseCase() -> CustomExerciseAdding {
        AddCustomExerciseUseCase(repository: repository)
    }
    
    func makeEditCustomExerciseUseCase() -> CustomExerciseEditing {
        EditCustomExerciseUseCase(repository: repository)
    }
}
