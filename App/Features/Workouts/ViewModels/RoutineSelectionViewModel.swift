import Foundation
import WorkoutsDomain

/// ViewModel for the routine selection screen
@Observable
@MainActor
final class RoutineSelectionViewModel {
    var routines: [RoutineItemViewModel] = []
    var isLoading = false
    var error: Error?
    
    private let loadRoutinesUseCase: RoutinesLoading
    private var loadedRoutines: [Routine] = []
    
    init(loadRoutinesUseCase: RoutinesLoading) {
        self.loadRoutinesUseCase = loadRoutinesUseCase
    }
    
    func loadRoutines() {
        isLoading = true
        error = nil
        
        loadRoutinesUseCase.load { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let routines):
                    self?.loadedRoutines = routines
                    self?.routines = routines.map { RoutineItemViewModel(routine: $0) }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func routine(for id: UUID) -> Routine? {
        loadedRoutines.first { $0.id == id }
    }
}

/// ViewModel for a single routine item
struct RoutineItemViewModel: Identifiable {
    let id: UUID
    let name: String
    let exerciseCount: Int
    let exercises: [String]
    
    init(routine: Routine) {
        self.id = routine.id
        self.name = routine.name
        self.exerciseCount = routine.exercises.count
        self.exercises = routine.exercises.map { $0.name }
    }
    
    var exerciseSummary: String {
        let displayExercises = exercises.prefix(3)
        let summary = displayExercises.joined(separator: ", ")
        if exercises.count > 3 {
            return "\(summary) +\(exercises.count - 3) more"
        }
        return summary
    }
}
