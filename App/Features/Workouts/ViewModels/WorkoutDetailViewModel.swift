import Foundation
import WorkoutsDomain

/// ViewModel for the workout detail screen
@Observable
@MainActor
final class WorkoutDetailViewModel {
    var workout: WorkoutDetailItem?
    var statistics: WorkoutStatisticsViewModel?
    var isLoading = false
    var error: Error?
    
    private let workoutId: UUID
    private let loadWorkoutsUseCase: WorkoutsLoading
    private let calculateStatisticsUseCase: WorkoutStatisticsCalculating
    
    init(
        workoutId: UUID,
        loadWorkoutsUseCase: WorkoutsLoading,
        calculateStatisticsUseCase: WorkoutStatisticsCalculating
    ) {
        self.workoutId = workoutId
        self.loadWorkoutsUseCase = loadWorkoutsUseCase
        self.calculateStatisticsUseCase = calculateStatisticsUseCase
    }
    
    func loadWorkoutDetail() {
        isLoading = true
        error = nil
        
        loadWorkoutsUseCase.load { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let workouts):
                    if let workout = workouts.first(where: { $0.id == self.workoutId }) {
                        self.workout = WorkoutDetailItem(workout: workout)
                        self.calculateStatistics(for: workout)
                    } else {
                        self.error = WorkoutError.notFound
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
    private func calculateStatistics(for workout: Workout) {
        let stats = calculateStatisticsUseCase.calculate(for: workout, duration: nil)
        self.statistics = WorkoutStatisticsViewModel(stats: stats)
    }
}

/// Detailed workout information for display
struct WorkoutDetailItem: Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let exercises: [ExerciseDetailItem]
    let notes: String?
    
    init(workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.date = workout.date
        self.exercises = workout.exercises.map { ExerciseDetailItem(exercise: $0) }
        self.notes = workout.notes
    }
}

/// Exercise information for detail display
struct ExerciseDetailItem: Identifiable {
    let id: UUID
    let name: String
    let sets: [SetDetailItem]
    let notes: String?
    let supersetId: UUID?
    
    init(exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.sets = exercise.sets.enumerated().map { SetDetailItem(set: $1, index: $0 + 1) }
        self.notes = exercise.notes
        self.supersetId = exercise.supersetID
    }
}

/// Set information for detail display
struct SetDetailItem: Identifiable {
    let id: UUID
    let index: Int
    let weight: Double?
    let reps: Int?
    let isCompleted: Bool
    
    init(set: ExerciseSet, index: Int) {
        self.id = set.id
        self.index = index
        self.weight = set.weight
        self.reps = set.repetitions
        self.isCompleted = set.repetitions != nil
    }
    
    var displayText: String {
        guard isCompleted else { return "—" }
        let weightText = weight.map { "\($0.formatted()) kg" } ?? "—"
        let repsText = reps.map { "\($0) reps" } ?? "—"
        return "\(weightText) × \(repsText)"
    }
}

/// Statistics for a completed workout
struct WorkoutStatisticsViewModel {
    let totalVolume: Double
    let totalSets: Int
    let totalReps: Int
    
    init(stats: WorkoutStatistics) {
        self.totalVolume = stats.totalVolume
        self.totalSets = stats.setCount
        self.totalReps = stats.totalReps
    }
    
    var formattedVolume: String {
        "\(totalVolume.formatted()) kg"
    }
}

/// Custom workout errors
enum WorkoutError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Workout not found"
        }
    }
}
