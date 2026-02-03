import Foundation
import WorkoutsDomain

/// Factory for creating Workouts-related use cases
@MainActor
final class WorkoutsUseCaseFactory: Sendable {
    private let workoutRepository: WorkoutRepository
    private let routineRepository: RoutineRepository
    private let exerciseHistoryRepository: ExerciseHistoryRepository
    private let exerciseHistoryProvider: ExerciseHistoryProviding
    
    init(
        workoutRepository: WorkoutRepository,
        routineRepository: RoutineRepository,
        exerciseHistoryRepository: ExerciseHistoryRepository,
        exerciseHistoryProvider: ExerciseHistoryProviding
    ) {
        self.workoutRepository = workoutRepository
        self.routineRepository = routineRepository
        self.exerciseHistoryRepository = exerciseHistoryRepository
        self.exerciseHistoryProvider = exerciseHistoryProvider
    }
    
    // MARK: - Workout Loading
    
    func makeLoadWorkoutsUseCase() -> WorkoutsLoading {
        LoadWorkoutsUseCase(repository: workoutRepository)
    }
    
    // MARK: - Workout Creation
    
    func makeStartEmptyWorkoutUseCase() -> EmptyWorkoutStarting {
        StartEmptyWorkoutUseCase(
            scheduler: makeWorkoutScheduler(),
            currentDate: { Date() }
        )
    }
    
    func makeStartRoutineUseCase() -> RoutineStarting {
        StartRoutineUseCase(
            routineRepository: routineRepository,
            workoutScheduler: makeWorkoutScheduler(),
            currentDate: { Date() },
            uuid: { UUID() }
        )
    }
    
    private func makeWorkoutScheduler() -> WorkoutScheduling {
        ScheduleWorkoutUseCase(repository: workoutRepository)
    }
    
    func makeScheduleWorkoutUseCase() -> WorkoutScheduling {
        makeWorkoutScheduler()
    }
    
    // MARK: - Workout Management
    
    func makeFinishWorkoutUseCase() -> WorkoutFinishing {
        FinishWorkoutUseCase(repository: workoutRepository)
    }
    
    func makeDeleteWorkoutUseCase() -> WorkoutDeleting {
        DeleteWorkoutUseCase(repository: workoutRepository)
    }
    
    // MARK: - Exercise Set Logging
    
    func makeExerciseSetLoggingUseCase() -> ExerciseSetLogging {
        ExerciseSetLoggingUseCase(
            repository: workoutRepository,
            historyProvider: exerciseHistoryProvider
        )
    }
    
    func makeUpdateExerciseNotesUseCase() -> ExerciseNotesUpdating {
        UpdateExerciseNotesUseCase(repository: workoutRepository)
    }
    
    // MARK: - Routine Management
    
    func makeLoadRoutinesUseCase() -> RoutinesLoading {
        LoadRoutinesUseCase(repository: routineRepository)
    }
    
    // MARK: - Exercise History
    
    func makeLoadExerciseHistoryUseCase() -> ExerciseHistoryLoading {
        LoadExerciseHistoryUseCase(repository: exerciseHistoryRepository)
    }
    
    // MARK: - Superset Management
    
    func makeLinkExercisesToSupersetUseCase() -> WorkoutSupersetLinking {
        LinkExercisesToSupersetUseCase(repository: workoutRepository)
    }
    
    func makeRemoveExerciseFromSupersetUseCase() -> WorkoutSupersetUnlinking {
        RemoveExerciseFromSupersetUseCase(repository: workoutRepository)
    }
    
    // MARK: - Exercise Reordering
    
    func makeReorderExercisesUseCase() -> WorkoutExerciseReordering {
        ReorderWorkoutExercisesUseCase(repository: workoutRepository)
    }
    
    // MARK: - Statistics
    
    func makeCalculateWorkoutStatisticsUseCase() -> WorkoutStatisticsCalculating {
        CalculateWorkoutStatisticsUseCase()
    }
}
