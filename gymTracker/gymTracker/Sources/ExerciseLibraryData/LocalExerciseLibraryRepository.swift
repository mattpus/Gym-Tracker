import Foundation

public final class LocalExerciseLibraryRepository: ExerciseLibraryRepository {
    private let store: ExerciseLibraryStore
    private let seedLoader: ExerciseLibrarySeedLoading
    
    public init(store: ExerciseLibraryStore, seedLoader: ExerciseLibrarySeedLoading) {
        self.store = store
        self.seedLoader = seedLoader
    }
    
    public func loadAll() throws -> [LibraryExercise] {
        try seedIfNeeded()
        return try store.loadAll().compactMap { $0.toLibraryExercise() }
    }
    
    public func save(_ exercise: LibraryExercise) throws {
        var exercises = try store.loadAll()
        
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = LocalLibraryExercise.from(exercise)
        } else {
            exercises.append(LocalLibraryExercise.from(exercise))
        }
        
        try store.save(exercises)
    }
    
    public func delete(_ exerciseId: UUID) throws {
        try store.delete(exerciseId)
    }
    
    public func search(query: String) throws -> [LibraryExercise] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedQuery.isEmpty else {
            return try loadAll()
        }
        
        return try loadAll().filter { exercise in
            exercise.name.lowercased().contains(trimmedQuery)
        }
    }
    
    public func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise] {
        try loadAll().filter { exercise in
            exercise.primaryMuscleGroup == muscleGroup ||
            exercise.secondaryMuscleGroups.contains(muscleGroup)
        }
    }
    
    public func exercise(byId id: UUID) throws -> LibraryExercise? {
        try loadAll().first { $0.id == id }
    }
    
    private func seedIfNeeded() throws {
        guard try !store.hasSeedData() else { return }
        
        let seedExercises = try seedLoader.loadSeedExercises()
        let localExercises = seedExercises.map { LocalLibraryExercise.from($0) }
        try store.save(localExercises)
    }
}
