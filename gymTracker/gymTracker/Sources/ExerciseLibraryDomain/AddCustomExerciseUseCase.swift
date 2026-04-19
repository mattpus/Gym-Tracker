import Foundation

public enum AddCustomExerciseError: Error, Equatable {
    case exerciseNameEmpty
    case exerciseAlreadyExists(name: String)
}

public final class AddCustomExerciseUseCase: CustomExerciseAdding {
    private let repository: ExerciseLibraryRepository
    
    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    public func add(_ exercise: LibraryExercise) throws {
        guard !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AddCustomExerciseError.exerciseNameEmpty
        }
        
        let existing = try repository.search(query: exercise.name)
        if existing.contains(where: { $0.name.lowercased() == exercise.name.lowercased() }) {
            throw AddCustomExerciseError.exerciseAlreadyExists(name: exercise.name)
        }
        
        let customExercise = LibraryExercise(
            id: exercise.id,
            name: exercise.name,
            primaryMuscleGroup: exercise.primaryMuscleGroup,
            secondaryMuscleGroups: exercise.secondaryMuscleGroups,
            equipmentType: exercise.equipmentType,
            isCustom: true
        )
        
        try repository.save(customExercise)
    }
}
