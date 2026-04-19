import Foundation

public final class UserDefaultsExerciseLibraryStore: ExerciseLibraryStore {
    private let userDefaults: UserDefaults
    private let key: String
    
    public init(userDefaults: UserDefaults = .standard, key: String = "com.gymtracker.exerciseLibrary") {
        self.userDefaults = userDefaults
        self.key = key
    }
    
    public func loadAll() throws -> [LocalLibraryExercise] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([LocalLibraryExercise].self, from: data)
    }
    
    public func save(_ exercises: [LocalLibraryExercise]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(exercises)
        userDefaults.set(data, forKey: key)
    }
    
    public func delete(_ exerciseId: UUID) throws {
        var exercises = try loadAll()
        exercises.removeAll { $0.id == exerciseId }
        try save(exercises)
    }
    
    public func hasSeedData() throws -> Bool {
        userDefaults.data(forKey: key) != nil
    }
}
