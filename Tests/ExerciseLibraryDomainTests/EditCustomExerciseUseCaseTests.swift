import XCTest
@testable import ExerciseLibraryDomain

final class EditCustomExerciseUseCaseTests: XCTestCase {
    
    func test_update_updatesCustomExercise() throws {
        let exerciseId = UUID()
        let existingExercise = LibraryExercise(
            id: exerciseId,
            name: "My Exercise",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell,
            isCustom: true
        )
        let repository = MockExerciseLibraryRepository(exercises: [existingExercise])
        let sut = EditCustomExerciseUseCase(repository: repository)
        
        let updated = LibraryExercise(
            id: exerciseId,
            name: "Updated Exercise",
            primaryMuscleGroup: .back,
            equipmentType: .cable,
            isCustom: true
        )
        
        try sut.update(updated)
        
        let result = try repository.exercise(byId: exerciseId)
        XCTAssertEqual(result?.name, "Updated Exercise")
        XCTAssertEqual(result?.primaryMuscleGroup, .back)
    }
    
    func test_update_throwsErrorWhenExerciseNotFound() {
        let repository = MockExerciseLibraryRepository()
        let sut = EditCustomExerciseUseCase(repository: repository)
        
        let exercise = LibraryExercise(
            id: UUID(),
            name: "Nonexistent",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell
        )
        
        XCTAssertThrowsError(try sut.update(exercise)) { error in
            XCTAssertEqual(error as? EditCustomExerciseError, .exerciseNotFound)
        }
    }
    
    func test_update_throwsErrorForBuiltInExercise() throws {
        let exerciseId = UUID()
        let builtIn = LibraryExercise(
            id: exerciseId,
            name: "Bench Press",
            primaryMuscleGroup: .chest,
            equipmentType: .barbell,
            isCustom: false
        )
        let repository = MockExerciseLibraryRepository(exercises: [builtIn])
        let sut = EditCustomExerciseUseCase(repository: repository)
        
        let updated = LibraryExercise(
            id: exerciseId,
            name: "Modified Bench",
            primaryMuscleGroup: .chest,
            equipmentType: .barbell
        )
        
        XCTAssertThrowsError(try sut.update(updated)) { error in
            XCTAssertEqual(error as? EditCustomExerciseError, .cannotEditBuiltInExercise)
        }
    }
    
    func test_update_throwsErrorForEmptyName() throws {
        let exerciseId = UUID()
        let existingExercise = LibraryExercise(
            id: exerciseId,
            name: "My Exercise",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell,
            isCustom: true
        )
        let repository = MockExerciseLibraryRepository(exercises: [existingExercise])
        let sut = EditCustomExerciseUseCase(repository: repository)
        
        let updated = LibraryExercise(
            id: exerciseId,
            name: "  ",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell
        )
        
        XCTAssertThrowsError(try sut.update(updated)) { error in
            XCTAssertEqual(error as? EditCustomExerciseError, .exerciseNameEmpty)
        }
    }
}
