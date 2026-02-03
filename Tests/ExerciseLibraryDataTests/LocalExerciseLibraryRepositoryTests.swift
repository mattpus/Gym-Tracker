import XCTest
@testable import ExerciseLibraryData
@testable import ExerciseLibraryDomain

final class LocalExerciseLibraryRepositoryTests: XCTestCase {
    
    func test_loadAll_seedsDataOnFirstLoad() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let exercises = try sut.loadAll()
        
        XCTAssertEqual(exercises.count, 2)
    }
    
    func test_loadAll_doesNotReseedWhenDataExists() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        _ = try sut.loadAll()
        _ = try sut.loadAll()
        
        XCTAssertEqual(seedLoader.loadCallCount, 1)
    }
    
    func test_save_addsNewExercise() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: [])
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let exercise = LibraryExercise(
            id: UUID(),
            name: "Custom Exercise",
            primaryMuscleGroup: .chest,
            equipmentType: .dumbbell,
            isCustom: true
        )
        
        try sut.save(exercise)
        
        let loaded = try sut.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.name, "Custom Exercise")
    }
    
    func test_save_updatesExistingExercise() throws {
        let store = InMemoryExerciseLibraryStore()
        let exerciseId = UUID()
        let seedLoader = MockSeedLoader(exercises: [
            LibraryExercise(id: exerciseId, name: "Original", primaryMuscleGroup: .chest, equipmentType: .barbell)
        ])
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        _ = try sut.loadAll()
        
        let updated = LibraryExercise(
            id: exerciseId,
            name: "Updated",
            primaryMuscleGroup: .back,
            equipmentType: .cable
        )
        try sut.save(updated)
        
        let loaded = try sut.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.name, "Updated")
    }
    
    func test_search_returnsMatchingExercises() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let results = try sut.search(query: "bench")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bench Press")
    }
    
    func test_search_returnsAllForEmptyQuery() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let results = try sut.search(query: "")
        
        XCTAssertEqual(results.count, 2)
    }
    
    func test_exercisesForMuscleGroup_returnsMatchingExercises() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let results = try sut.exercises(for: .chest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bench Press")
    }
    
    func test_exercisesForMuscleGroup_includesSecondaryMuscles() throws {
        let store = InMemoryExerciseLibraryStore()
        let seedLoader = MockSeedLoader(exercises: makeSeedExercises())
        let sut = LocalExerciseLibraryRepository(store: store, seedLoader: seedLoader)
        
        let results = try sut.exercises(for: .triceps)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bench Press")
    }
    
    // MARK: - Helpers
    
    private func makeSeedExercises() -> [LibraryExercise] {
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

final class MockSeedLoader: ExerciseLibrarySeedLoading {
    private let exercises: [LibraryExercise]
    private(set) var loadCallCount = 0
    
    init(exercises: [LibraryExercise]) {
        self.exercises = exercises
    }
    
    func loadSeedExercises() throws -> [LibraryExercise] {
        loadCallCount += 1
        return exercises
    }
}
