import Foundation

public final class InMemoryExerciseLibraryStore: ExerciseLibraryStore {
    private var exercises: [LocalLibraryExercise] = []
    private var seeded = false
    
    public init() {}
    
    public func loadAll() throws -> [LocalLibraryExercise] {
        exercises
    }
    
    public func save(_ exercises: [LocalLibraryExercise]) throws {
        self.exercises = exercises
        self.seeded = true
    }
    
    public func delete(_ exerciseId: UUID) throws {
        exercises.removeAll { $0.id == exerciseId }
    }
    
    public func hasSeedData() throws -> Bool {
        seeded
    }
}
