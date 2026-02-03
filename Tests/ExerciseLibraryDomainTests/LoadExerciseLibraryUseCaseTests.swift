import XCTest
@testable import ExerciseLibraryDomain

final class LoadExerciseLibraryUseCaseTests: XCTestCase {
    
    func test_load_returnsExercisesFromRepository() throws {
        let exercises = makeExercises()
        let repository = MockExerciseLibraryRepository(exercises: exercises)
        let sut = LoadExerciseLibraryUseCase(repository: repository)
        
        let result = try sut.load()
        
        XCTAssertEqual(result, exercises)
    }
    
    func test_load_throwsErrorWhenRepositoryFails() {
        let repository = MockExerciseLibraryRepository(error: NSError(domain: "test", code: 1))
        let sut = LoadExerciseLibraryUseCase(repository: repository)
        
        XCTAssertThrowsError(try sut.load())
    }
    
    // MARK: - Helpers
    
    private func makeExercises() -> [LibraryExercise] {
        [
            LibraryExercise(
                id: UUID(),
                name: "Bench Press",
                primaryMuscleGroup: .chest,
                secondaryMuscleGroups: [.triceps, .shoulders],
                equipmentType: .barbell
            ),
            LibraryExercise(
                id: UUID(),
                name: "Squat",
                primaryMuscleGroup: .quadriceps,
                secondaryMuscleGroups: [.glutes, .hamstrings],
                equipmentType: .barbell
            )
        ]
    }
}

final class MockExerciseLibraryRepository: ExerciseLibraryRepository {
    private var exercises: [LibraryExercise]
    private let error: Error?
    
    init(exercises: [LibraryExercise] = [], error: Error? = nil) {
        self.exercises = exercises
        self.error = error
    }
    
    func loadAll() throws -> [LibraryExercise] {
        if let error { throw error }
        return exercises
    }
    
    func save(_ exercise: LibraryExercise) throws {
        if let error { throw error }
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
        } else {
            exercises.append(exercise)
        }
    }
    
    func delete(_ exerciseId: UUID) throws {
        if let error { throw error }
        exercises.removeAll { $0.id == exerciseId }
    }
    
    func search(query: String) throws -> [LibraryExercise] {
        if let error { throw error }
        return exercises.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise] {
        if let error { throw error }
        return exercises.filter { $0.primaryMuscleGroup == muscleGroup }
    }
    
    func exercise(byId id: UUID) throws -> LibraryExercise? {
        if let error { throw error }
        return exercises.first { $0.id == id }
    }
}
