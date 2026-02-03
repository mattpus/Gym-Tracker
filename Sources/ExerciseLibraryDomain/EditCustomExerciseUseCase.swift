import Foundation

public enum EditCustomExerciseError: Error, Equatable {
    case exerciseNotFound
    case cannotEditBuiltInExercise
    case exerciseNameEmpty
}

public final class EditCustomExerciseUseCase: CustomExerciseEditing {
    private let repository: ExerciseLibraryRepository
    
    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    public func update(_ exercise: LibraryExercise) throws {
        guard let existing = try repository.exercise(byId: exercise.id) else {
            throw EditCustomExerciseError.exerciseNotFound
        }
        
        guard existing.isCustom else {
            throw EditCustomExerciseError.cannotEditBuiltInExercise
        }
        
        guard !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw EditCustomExerciseError.exerciseNameEmpty
        }
        
        let updatedExercise = LibraryExercise(
            id: exercise.id,
            name: exercise.name,
            primaryMuscleGroup: exercise.primaryMuscleGroup,
            secondaryMuscleGroups: exercise.secondaryMuscleGroups,
            equipmentType: exercise.equipmentType,
            isCustom: true
        )
        
        try repository.save(updatedExercise)
    }
}
