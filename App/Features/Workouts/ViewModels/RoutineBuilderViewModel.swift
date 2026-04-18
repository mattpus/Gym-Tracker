import Foundation
import ExerciseLibraryDomain
import WorkoutsDomain

@Observable
@MainActor
final class RoutineBuilderViewModel {
    var name: String = ""
    var selectedExercises: [SelectableExerciseItem] = []
    var isSaving = false
    var errorMessage: String?
    
    private let createRoutineUseCase: RoutineBuilding
    
    init(createRoutineUseCase: RoutineBuilding) {
        self.createRoutineUseCase = createRoutineUseCase
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedExercises.isEmpty
    }
    
    func addExercise(_ exercise: SelectableExerciseItem) {
        guard !selectedExercises.contains(where: { $0.id == exercise.id }) else { return }
        selectedExercises.append(exercise)
    }
    
    func removeExercises(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        selectedExercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        errorMessage = nil
        isSaving = true
        
        let routine = Routine(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            exercises: selectedExercises.enumerated().map { index, exercise in
                RoutineExercise(
                    id: exercise.id,
                    name: exercise.name,
                    notes: nil,
                    sets: [
                        RoutineSet(order: 0),
                        RoutineSet(order: 1)
                    ]
                )
            }
        )
        
        createRoutineUseCase.create(routine) { [weak self] result in
            Task { @MainActor in
                self?.isSaving = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
