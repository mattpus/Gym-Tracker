import Foundation
import ExerciseLibraryDomain
import WorkoutsDomain

/// ViewModel for selecting exercises to add to a workout
@Observable
@MainActor
final class ExerciseSelectionViewModel {
    var exercises: [SelectableExerciseItem] = []
    var searchQuery = ""
    var selectedMuscleGroup: ExerciseLibraryDomain.MuscleGroup?
    var isLoading = false
    var error: Error?
    
    private let loadExerciseLibraryUseCase: ExerciseLibraryDomain.ExerciseLibraryLoading
    private let searchExerciseLibraryUseCase: ExerciseLibraryDomain.ExerciseLibrarySearching
    private var allExercises: [SelectableExerciseItem] = []
    
    init(
        loadExerciseLibraryUseCase: ExerciseLibraryDomain.ExerciseLibraryLoading,
        searchExerciseLibraryUseCase: ExerciseLibraryDomain.ExerciseLibrarySearching
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
    
    var availableMuscleGroups: [ExerciseLibraryDomain.MuscleGroup] {
        ExerciseLibraryDomain.MuscleGroup.allCases
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
    
    func filterByMuscleGroup(_ muscleGroup: ExerciseLibraryDomain.MuscleGroup?) {
        selectedMuscleGroup = muscleGroup
    }
    
    func clearFilters() {
        selectedMuscleGroup = nil
        searchQuery = ""
        exercises = allExercises
    }
    
    /// Creates a workout Exercise from a library exercise with 2 default empty sets
    func createWorkoutExercise(from item: SelectableExerciseItem) -> WorkoutsDomain.Exercise {
        let defaultSets = [
            WorkoutsDomain.ExerciseSet(id: UUID(), order: 0),
            WorkoutsDomain.ExerciseSet(id: UUID(), order: 1)
        ]
        
        return WorkoutsDomain.Exercise(
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
    let primaryMuscleGroup: ExerciseLibraryDomain.MuscleGroup
    let secondaryMuscleGroups: [ExerciseLibraryDomain.MuscleGroup]
    let equipmentType: ExerciseLibraryDomain.EquipmentType
    let isCustom: Bool
    
    init(exercise: ExerciseLibraryDomain.LibraryExercise) {
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
        primaryMuscleGroup: ExerciseLibraryDomain.MuscleGroup,
        secondaryMuscleGroups: [ExerciseLibraryDomain.MuscleGroup] = [],
        equipmentType: ExerciseLibraryDomain.EquipmentType = .barbell,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryMuscleGroup = primaryMuscleGroup
        self.secondaryMuscleGroups = secondaryMuscleGroups
        self.equipmentType = equipmentType
        self.isCustom = isCustom
    }
    
    var allMuscleGroups: [ExerciseLibraryDomain.MuscleGroup] {
        [primaryMuscleGroup] + secondaryMuscleGroups
    }
}
