import Foundation
import WorkoutsDomain

/// ViewModel for the workouts list screen
@Observable
@MainActor
final class WorkoutsListViewModel {
    var workouts: [WorkoutItemViewModel] = []
    var isLoading = false
    var error: Error?
    
    private let loadWorkoutsUseCase: WorkoutsLoading
    private let deleteWorkoutUseCase: WorkoutDeleting
    
    init(
        loadWorkoutsUseCase: WorkoutsLoading,
        deleteWorkoutUseCase: WorkoutDeleting
    ) {
        self.loadWorkoutsUseCase = loadWorkoutsUseCase
        self.deleteWorkoutUseCase = deleteWorkoutUseCase
    }
    
    func loadWorkouts() {
        isLoading = true
        error = nil
        
        loadWorkoutsUseCase.load { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let workouts):
                    self?.workouts = workouts.map { WorkoutItemViewModel(workout: $0) }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            let workoutVM = workouts[index]
            deleteWorkoutUseCase.delete(workoutID: workoutVM.id) { [weak self] result in
                Task { @MainActor in
                    if case .success = result {
                        self?.workouts.remove(at: index)
                    }
                }
            }
        }
    }
}

/// ViewModel for a single workout item in the list
struct WorkoutItemViewModel: Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let exerciseCount: Int
    let totalSets: Int
    
    init(workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.date = workout.date
        self.exerciseCount = workout.exercises.count
        self.totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        // Duration is calculated from exercises if needed
        return ""
    }
}
