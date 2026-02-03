import Foundation
import AnalyticsDomain
import WorkoutsDomain
import ExerciseLibraryDomain
import AnalyticsData

/// Factory for creating Analytics-related use cases
@MainActor
final class AnalyticsUseCaseFactory: Sendable {
    private let workoutRepository: WorkoutRepository
    private let exerciseLibraryRepository: ExerciseLibraryRepository
    
    init(
        workoutRepository: WorkoutRepository,
        exerciseLibraryRepository: ExerciseLibraryRepository
    ) {
        self.workoutRepository = workoutRepository
        self.exerciseLibraryRepository = exerciseLibraryRepository
    }
    
    func makeWorkoutFrequencyUseCase() -> WorkoutFrequencyCalculating {
        GetWorkoutFrequencyUseCase(repository: makeWorkoutDataRepository())
    }
    
    func makeWeightProgressionUseCase() -> WeightProgressionCalculating {
        GetWeightProgressionUseCase(repository: makeWorkoutDataRepository())
    }
    
    func makeVolumeProgressionUseCase() -> VolumeProgressionCalculating {
        GetVolumeProgressionUseCase(repository: makeWorkoutDataRepository())
    }
    
    func makeMuscleGroupDistributionUseCase() -> MuscleGroupDistributionCalculating {
        GetMuscleGroupDistributionUseCase(repository: makeWorkoutDataRepository())
    }
    
    func makeRecoveryStatusUseCase() -> RecoveryStatusCalculating {
        GetRecoveryStatusUseCase(repository: makeWorkoutDataRepository())
    }
    
    func makeWeeklyInsightsUseCase() -> WeeklyInsightsGenerating {
        GenerateWeeklyInsightsUseCase(repository: makeWorkoutDataRepository())
    }
    
    // MARK: - Private Helpers
    
    private func makeWorkoutDataRepository() -> WorkoutDataRepository {
        LocalWorkoutDataRepository(workoutRepository: workoutRepository)
    }
}
