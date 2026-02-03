import Foundation
import ExerciseLibraryDomain

/// ViewModel for the Exercise Library
@Observable
@MainActor
final class ExerciseLibraryViewModel {
    var exercises: [LibraryExerciseItem] = []
    var searchQuery = ""
    var selectedMuscleGroup: MuscleGroup?
    var isLoading = false
    var error: Error?
    
    private let loadExerciseLibraryUseCase: ExerciseLibraryLoading
    private let searchExerciseLibraryUseCase: ExerciseLibrarySearching
    
    init(
        loadExerciseLibraryUseCase: ExerciseLibraryLoading,
        searchExerciseLibraryUseCase: ExerciseLibrarySearching
    ) {
        self.loadExerciseLibraryUseCase = loadExerciseLibraryUseCase
        self.searchExerciseLibraryUseCase = searchExerciseLibraryUseCase
    }
    
    var filteredExercises: [LibraryExerciseItem] {
        var result = exercises
        
        if let muscleGroup = selectedMuscleGroup {
            result = result.filter { $0.primaryMuscleGroup == muscleGroup }
        }
        
        return result
    }
    
    func loadExercises() {
        isLoading = true
        error = nil
        
        do {
            let loadedExercises = try loadExerciseLibraryUseCase.load()
            exercises = loadedExercises.map { LibraryExerciseItem(exercise: $0) }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func search() {
        guard !searchQuery.isEmpty else {
            loadExercises()
            return
        }
        
        isLoading = true
        
        do {
            let searchResults = try searchExerciseLibraryUseCase.search(query: searchQuery)
            exercises = searchResults.map { LibraryExerciseItem(exercise: $0) }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct LibraryExerciseItem: Identifiable {
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
}

/// ViewModel for Exercise Detail
@Observable
@MainActor
final class ExerciseDetailViewModel {
    var exercise: LibraryExerciseItem?
    var isLoading = false
    
    private let exerciseId: UUID
    private let loadExerciseLibraryUseCase: ExerciseLibraryLoading
    
    init(exerciseId: UUID, loadExerciseLibraryUseCase: ExerciseLibraryLoading) {
        self.exerciseId = exerciseId
        self.loadExerciseLibraryUseCase = loadExerciseLibraryUseCase
    }
    
    func loadExercise() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let exercises = try loadExerciseLibraryUseCase.load()
            if let found = exercises.first(where: { $0.id == exerciseId }) {
                exercise = LibraryExerciseItem(exercise: found)
            }
        } catch {
            // Handle error
        }
    }
}

/// ViewModel for Adding Custom Exercise
@Observable
@MainActor
final class AddCustomExerciseViewModel {
    var name = ""
    var primaryMuscleGroup: MuscleGroup = .chest
    var secondaryMuscleGroups: Set<MuscleGroup> = []
    var equipmentType: EquipmentType = .barbell
    var isSaving = false
    var error: Error?
    
    private let addCustomExerciseUseCase: CustomExerciseAdding
    
    init(addCustomExerciseUseCase: CustomExerciseAdding) {
        self.addCustomExerciseUseCase = addCustomExerciseUseCase
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        guard isValid else {
            completion(false)
            return
        }
        
        isSaving = true
        
        let exercise = LibraryExercise(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroups: Array(secondaryMuscleGroups),
            equipmentType: equipmentType,
            isCustom: true
        )
        
        do {
            try addCustomExerciseUseCase.add(exercise)
            isSaving = false
            completion(true)
        } catch {
            self.error = error
            isSaving = false
            completion(false)
        }
    }
}
