import XCTest
@testable import ExerciseLibraryDomain

final class SearchExerciseLibraryUseCaseTests: XCTestCase {
    
    func test_search_returnsMatchingExercises() throws {
        let exercises = makeExercises()
        let repository = MockExerciseLibraryRepository(exercises: exercises)
        let sut = SearchExerciseLibraryUseCase(repository: repository)
        
        let result = try sut.search(query: "bench")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Bench Press")
    }
    
    func test_exercisesForMuscleGroup_returnsMatchingExercises() throws {
        let exercises = makeExercises()
        let repository = MockExerciseLibraryRepository(exercises: exercises)
        let sut = SearchExerciseLibraryUseCase(repository: repository)
        
        let result = try sut.exercises(for: .chest)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Bench Press")
    }
    
    // MARK: - Helpers
    
    private func makeExercises() -> [LibraryExercise] {
        [
            LibraryExercise(
                id: UUID(),
                name: "Bench Press",
                primaryMuscleGroup: .chest,
                secondaryMuscleGroups: [.triceps],
                equipmentType: .barbell
            ),
            LibraryExercise(
                id: UUID(),
                name: "Squat",
                primaryMuscleGroup: .quadriceps,
                equipmentType: .barbell
            )
        ]
    }
}
