import Foundation

public protocol CustomExerciseDeleting {
    func delete(exerciseId: UUID) throws
}

public enum DeleteCustomExerciseError: Error, Equatable {
    case exerciseNotFound
    case cannotDeleteBuiltInExercise
}

public final class DeleteCustomExerciseUseCase: CustomExerciseDeleting {
    private let repository: ExerciseLibraryRepository

    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }

    public func delete(exerciseId: UUID) throws {
        guard let exercise = try repository.exercise(byId: exerciseId) else {
            throw DeleteCustomExerciseError.exerciseNotFound
        }

        guard exercise.isCustom else {
            throw DeleteCustomExerciseError.cannotDeleteBuiltInExercise
        }

        try repository.delete(exerciseId)
    }
}
