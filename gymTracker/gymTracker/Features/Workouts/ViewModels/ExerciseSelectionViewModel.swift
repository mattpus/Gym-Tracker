import Foundation
import Observation

/// ViewModel for selecting exercises to add to a workout
@Observable
@MainActor
final class ExerciseSelectionViewModel {
    var exercises: [SelectableExerciseItem] = []
    var searchQuery = ""
    var selectedMuscleGroup: MuscleGroup?
    var isLoading = false
    var error: Error?
    
    private let loadExerciseLibraryUseCase: ExerciseLibraryLoading
    private let searchExerciseLibraryUseCase: ExerciseLibrarySearching
    private var allExercises: [SelectableExerciseItem] = []
    
    init(
        loadExerciseLibraryUseCase: ExerciseLibraryLoading,
        searchExerciseLibraryUseCase: ExerciseLibrarySearching
    ) {
        self.loadExerciseLibraryUseCase = loadExerciseLibraryUseCase
        self.searchExerciseLibraryUseCase = searchExerciseLibraryUseCase
    }
    
    // MARK: - Computed Properties
    
    var filteredExercises: [SelectableExerciseItem] {
        var result = exercises
        
        if let muscleGroup = selectedMuscleGroup {
            result = result.filter { 
                $0.primaryMuscleGroup == muscleGroup || 
                $0.secondaryMuscleGroups.contains(muscleGroup)
            }
        }
        
        return result
    }
    
    var availableMuscleGroups: [MuscleGroup] {
        MuscleGroup.allCases
    }
    
    // MARK: - Actions
    
    func loadExercises() {
        isLoading = true
        error = nil
        
        do {
            let loadedExercises = try loadExerciseLibraryUseCase.load()
            allExercises = loadedExercises.map { SelectableExerciseItem(exercise: $0) }
            exercises = allExercises
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            exercises = allExercises
            return
        }
        
        isLoading = true
        
        do {
            let searchResults = try searchExerciseLibraryUseCase.search(query: searchQuery)
            exercises = searchResults.map { SelectableExerciseItem(exercise: $0) }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func filterByMuscleGroup(_ muscleGroup: MuscleGroup?) {
        selectedMuscleGroup = muscleGroup
    }
    
    func clearFilters() {
        selectedMuscleGroup = nil
        searchQuery = ""
        exercises = allExercises
    }
    
    /// Creates a workout Exercise from a library exercise with 2 default empty sets
    func createWorkoutExercise(from item: SelectableExerciseItem) -> Exercise {
        let defaultSets = [
            ExerciseSet(id: UUID(), order: 0, type: .main),
            ExerciseSet(id: UUID(), order: 1, type: .main),
            ExerciseSet(id: UUID(), order: 2, type: .main)
        ]
        
        return Exercise(
            id: UUID(),
            name: item.name,
            notes: nil,
            sets: defaultSets
        )
    }
}

// MARK: - View Model Item

struct SelectableExerciseItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let primaryMuscleGroup: MuscleGroup
    let secondaryMuscleGroups: [MuscleGroup]
    let equipmentType: EquipmentType
    let isCustom: Bool
    
    init(exercise: LibraryExercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.primaryMuscleGroup = exercise.primaryMuscleGroup
        self.secondaryMuscleGroups = exercise.secondaryMuscleGroups
        self.equipmentType = exercise.equipmentType
        self.isCustom = exercise.isCustom
    }
    
    // For testing
    init(
        id: UUID = UUID(),
        name: String,
        primaryMuscleGroup: MuscleGroup,
        secondaryMuscleGroups: [MuscleGroup] = [],
        equipmentType: EquipmentType = .barbell,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryMuscleGroup = primaryMuscleGroup
        self.secondaryMuscleGroups = secondaryMuscleGroups
        self.equipmentType = equipmentType
        self.isCustom = isCustom
    }
    
    var allMuscleGroups: [MuscleGroup] {
        [primaryMuscleGroup] + secondaryMuscleGroups
    }
}
