import XCTest
@testable import ExerciseLibraryData

final class InMemoryExerciseLibraryStoreTests: XCTestCase {
    
    func test_loadAll_returnsEmptyInitially() throws {
        let sut = InMemoryExerciseLibraryStore()
        
        let exercises = try sut.loadAll()
        
        XCTAssertTrue(exercises.isEmpty)
    }
    
    func test_hasSeedData_returnsFalseInitially() throws {
        let sut = InMemoryExerciseLibraryStore()
        
        let result = try sut.hasSeedData()
        
        XCTAssertFalse(result)
    }
    
    func test_save_persistsExercises() throws {
        let sut = InMemoryExerciseLibraryStore()
        let exercises = makeExercises()
        
        try sut.save(exercises)
        
        let loaded = try sut.loadAll()
        XCTAssertEqual(loaded, exercises)
    }
    
    func test_save_setsHasSeedDataToTrue() throws {
        let sut = InMemoryExerciseLibraryStore()
        
        try sut.save(makeExercises())
        
        XCTAssertTrue(try sut.hasSeedData())
    }
    
    func test_delete_removesExercise() throws {
        let sut = InMemoryExerciseLibraryStore()
        let exercises = makeExercises()
        try sut.save(exercises)
        
        try sut.delete(exercises[0].id)
        
        let loaded = try sut.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, exercises[1].id)
    }
    
    // MARK: - Helpers
    
    private func makeExercises() -> [LocalLibraryExercise] {
        [
            LocalLibraryExercise(
                id: UUID(),
                name: "Bench Press",
                primaryMuscleGroup: "chest",
                secondaryMuscleGroups: ["triceps"],
                equipmentType: "barbell"
            ),
            LocalLibraryExercise(
                id: UUID(),
                name: "Squat",
                primaryMuscleGroup: "quadriceps",
                equipmentType: "barbell"
            )
        ]
    }
}
