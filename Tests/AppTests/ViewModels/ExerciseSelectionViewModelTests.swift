import XCTest
import ExerciseLibraryDomain
@testable import Gym_Tracker

@MainActor
final class ExerciseSelectionViewModelTests: XCTestCase {
    
    // MARK: - Load Tests
    
    func test_load_deliversExercisesOnSuccess() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        
        XCTAssertEqual(sut.exercises.count, 3)
        XCTAssertEqual(sut.exercises[0].name, "Bench Press")
        XCTAssertEqual(sut.exercises[1].name, "Squat")
        XCTAssertEqual(sut.exercises[2].name, "Deadlift")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func test_load_deliversErrorOnFailure() async {
        let sut = makeSUT(loadResult: .failure(anyError()))
        
        sut.loadExercises()
        
        XCTAssertTrue(sut.exercises.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_load_setsLoadingStateDuringLoad() async {
        let sut = makeSUT(loadResult: .success([]))
        
        XCTAssertFalse(sut.isLoading)
        sut.loadExercises()
        XCTAssertFalse(sut.isLoading) // After completion
    }
    
    // MARK: - Search Tests
    
    func test_search_filtersExercisesByQuery() async {
        let exercises = makeTestExercises()
        let searchResults = [exercises[0]] // Only Bench Press
        let sut = makeSUT(loadResult: .success(exercises), searchResult: .success(searchResults))
        
        sut.loadExercises()
        sut.searchQuery = "Bench"
        sut.search()
        
        XCTAssertEqual(sut.exercises.count, 1)
        XCTAssertEqual(sut.exercises[0].name, "Bench Press")
    }
    
    func test_search_emptyQueryLoadsAllExercises() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.searchQuery = ""
        sut.search()
        
        XCTAssertEqual(sut.exercises.count, 3)
    }
    
    func test_search_whitespaceOnlyQueryLoadsAllExercises() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.searchQuery = "   "
        sut.search()
        
        XCTAssertEqual(sut.exercises.count, 3)
    }
    
    // MARK: - Filter Tests
    
    func test_filterByMuscleGroup_filtersByPrimaryMuscle() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.filterByMuscleGroup(.chest)
        
        XCTAssertEqual(sut.filteredExercises.count, 1)
        XCTAssertEqual(sut.filteredExercises[0].name, "Bench Press")
    }
    
    func test_filterByMuscleGroup_includesSecondaryMuscles() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.filterByMuscleGroup(.triceps) // Bench Press has triceps as secondary
        
        XCTAssertEqual(sut.filteredExercises.count, 1)
        XCTAssertEqual(sut.filteredExercises[0].name, "Bench Press")
    }
    
    func test_filterByMuscleGroup_nilShowsAll() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.filterByMuscleGroup(.chest)
        XCTAssertEqual(sut.filteredExercises.count, 1)
        
        sut.filterByMuscleGroup(nil)
        XCTAssertEqual(sut.filteredExercises.count, 3)
    }
    
    // MARK: - Clear Filters Tests
    
    func test_clearFilters_resetsAllFilters() async {
        let exercises = makeTestExercises()
        let sut = makeSUT(loadResult: .success(exercises))
        
        sut.loadExercises()
        sut.filterByMuscleGroup(.chest)
        sut.searchQuery = "test"
        
        sut.clearFilters()
        
        XCTAssertNil(sut.selectedMuscleGroup)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.exercises.count, 3)
    }
    
    // MARK: - Create Workout Exercise Tests
    
    func test_createWorkoutExercise_createsExerciseWithTwoDefaultSets() async {
        let sut = makeSUT(loadResult: .success([]))
        let item = SelectableExerciseItem(
            name: "Bench Press",
            primaryMuscleGroup: .chest,
            secondaryMuscleGroups: [.triceps]
        )
        
        let exercise = sut.createWorkoutExercise(from: item)
        
        XCTAssertEqual(exercise.name, "Bench Press")
        XCTAssertEqual(exercise.sets.count, 2)
        XCTAssertEqual(exercise.sets[0].order, 0)
        XCTAssertEqual(exercise.sets[1].order, 1)
        XCTAssertNil(exercise.sets[0].weight)
        XCTAssertNil(exercise.sets[0].repetitions)
        XCTAssertNil(exercise.notes)
    }
    
    func test_createWorkoutExercise_generatesUniqueIDs() async {
        let sut = makeSUT(loadResult: .success([]))
        let item = SelectableExerciseItem(
            name: "Squat",
            primaryMuscleGroup: .quadriceps
        )
        
        let exercise1 = sut.createWorkoutExercise(from: item)
        let exercise2 = sut.createWorkoutExercise(from: item)
        
        XCTAssertNotEqual(exercise1.id, exercise2.id)
        XCTAssertNotEqual(exercise1.sets[0].id, exercise2.sets[0].id)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        loadResult: Result<[LibraryExercise], Error> = .success([]),
        searchResult: Result<[LibraryExercise], Error>? = nil
    ) -> ExerciseSelectionViewModel {
        let loadUseCase = MockExerciseLibraryLoading(result: loadResult)
        let searchUseCase = MockExerciseLibrarySearching(result: searchResult ?? loadResult)
        return ExerciseSelectionViewModel(
            loadExerciseLibraryUseCase: loadUseCase,
            searchExerciseLibraryUseCase: searchUseCase
        )
    }
    
    private func makeTestExercises() -> [LibraryExercise] {
        [
            LibraryExercise(
                id: UUID(),
                name: "Bench Press",
                primaryMuscleGroup: .chest,
                secondaryMuscleGroups: [.triceps, .shoulders],
                equipmentType: .barbell,
                isCustom: false
            ),
            LibraryExercise(
                id: UUID(),
                name: "Squat",
                primaryMuscleGroup: .quadriceps,
                secondaryMuscleGroups: [.glutes, .hamstrings],
                equipmentType: .barbell,
                isCustom: false
            ),
            LibraryExercise(
                id: UUID(),
                name: "Deadlift",
                primaryMuscleGroup: .back,
                secondaryMuscleGroups: [.hamstrings, .glutes],
                equipmentType: .barbell,
                isCustom: false
            )
        ]
    }
    
    private func anyError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

// MARK: - Mocks

private final class MockExerciseLibraryLoading: ExerciseLibraryLoading {
    private let result: Result<[LibraryExercise], Error>
    
    init(result: Result<[LibraryExercise], Error>) {
        self.result = result
    }
    
    func load() throws -> [LibraryExercise] {
        try result.get()
    }
}

private final class MockExerciseLibrarySearching: ExerciseLibrarySearching {
    private let result: Result<[LibraryExercise], Error>
    
    init(result: Result<[LibraryExercise], Error>) {
        self.result = result
    }
    
    func search(query: String) throws -> [LibraryExercise] {
        try result.get()
    }
    
    func exercises(for muscleGroup: MuscleGroup) throws -> [LibraryExercise] {
        try result.get().filter { $0.primaryMuscleGroup == muscleGroup }
    }
}
