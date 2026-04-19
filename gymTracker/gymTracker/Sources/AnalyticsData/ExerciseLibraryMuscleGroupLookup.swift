import Foundation

public final class ExerciseLibraryMuscleGroupLookup: ExerciseMuscleGroupLookup {
    private let repository: ExerciseLibraryRepository
    private var cache: [String: String] = [:]
    
    public init(repository: ExerciseLibraryRepository) {
        self.repository = repository
    }
    
    public func muscleGroup(for exerciseName: String) -> String? {
        let normalizedName = exerciseName.lowercased()
        
        if let cached = cache[normalizedName] {
            return cached
        }
        
        do {
            let exercises = try repository.search(query: exerciseName)
            if let match = exercises.first(where: { $0.name.lowercased() == normalizedName }) {
                let muscleGroup = match.primaryMuscleGroup.rawValue
                cache[normalizedName] = muscleGroup
                return muscleGroup
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    public func preloadCache() {
        do {
            let allExercises = try repository.loadAll()
            for exercise in allExercises {
                cache[exercise.name.lowercased()] = exercise.primaryMuscleGroup.rawValue
            }
        } catch {
            // Ignore cache errors
        }
    }
}
