import XCTest
@testable import ExerciseLibraryDomain

final class AddCustomExerciseUseCaseTests: XCTestCase {
    
    func test_add_savesCustomExercise() throws {
        let repository = MockExerciseLibraryRepository()
        let sut = AddCustomExerciseUseCase(repository: repository)
        
        let exercise = LibraryExercise(
            id: UUID(),
            name: "My Custom Exercise",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell
        )
        
        try sut.add(exercise)
        
        let saved = try repository.exercise(byId: exercise.id)
        XCTAssertNotNil(saved)
        XCTAssertTrue(saved?.isCustom ?? false)
    }
    
    func test_add_throwsErrorForEmptyName() {
        let repository = MockExerciseLibraryRepository()
        let sut = AddCustomExerciseUseCase(repository: repository)
        
        let exercise = LibraryExercise(
            id: UUID(),
            name: "   ",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell
        )
        
        XCTAssertThrowsError(try sut.add(exercise)) { error in
            XCTAssertEqual(error as? AddCustomExerciseError, .exerciseNameEmpty)
        }
    }
    
    func test_add_throwsErrorForDuplicateName() throws {
        let existingExercise = LibraryExercise(
            id: UUID(),
            name: "Bench Press",
            primaryMuscleGroup: .chest,
            equipmentType: .barbell
        )
        let repository = MockExerciseLibraryRepository(exercises: [existingExercise])
        let sut = AddCustomExerciseUseCase(repository: repository)
        
        let duplicate = LibraryExercise(
            id: UUID(),
            name: "bench press",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell
        )
        
        XCTAssertThrowsError(try sut.add(duplicate)) { error in
            XCTAssertEqual(error as? AddCustomExerciseError, .exerciseAlreadyExists(name: "bench press"))
        }
    }
}
