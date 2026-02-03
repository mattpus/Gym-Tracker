import Foundation
import CoreData
import WorkoutsDomain
import WorkoutsData
import ExerciseLibraryDomain
import ExerciseLibraryData
import AnalyticsDomain
import AnalyticsData
import ProgressionDomain
import ProgressionData

/// Central dependency container following Composition Root pattern.
/// All dependencies are created and wired here, then injected into coordinators and view models.
@MainActor
final class DependencyContainer: Sendable {
    
    // MARK: - Core Data Stack
    
    private lazy var storeURL: URL = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("GymTracker.sqlite")
    }()
    
    private(set) lazy var workoutStore: CoreDataWorkoutStore = {
        do {
            return try CoreDataWorkoutStore(storeURL: storeURL)
        } catch {
            fatalError("Failed to initialize Core Data store: \(error)")
        }
    }()
    
    // MARK: - Stores (CoreDataWorkoutStore implements both WorkoutStore and RoutineStore)
    
    var workoutStoreProtocol: WorkoutStore { workoutStore }
    var routineStoreProtocol: RoutineStore { workoutStore }
    
    // MARK: - Repositories
    
    private(set) lazy var workoutRepository: WorkoutRepository = {
        LocalWorkoutRepository(store: workoutStoreProtocol, currentDate: { Date() })
    }()
    
    private(set) lazy var routineRepository: RoutineRepository = {
        LocalRoutineRepository(store: routineStoreProtocol, currentDate: { Date() })
    }()
    
    private(set) lazy var exerciseHistoryRepository: ExerciseHistoryRepository = {
        LocalExerciseHistoryRepository(store: workoutStoreProtocol)
    }()
    
    private(set) lazy var exerciseHistoryProvider: ExerciseHistoryProviding = {
        LocalExerciseHistoryProvider(store: workoutStoreProtocol)
    }()
    
    private(set) lazy var exerciseLibraryStore: ExerciseLibraryStore = {
        UserDefaultsExerciseLibraryStore()
    }()
    
    private(set) lazy var exerciseLibraryRepository: ExerciseLibraryRepository = {
        let seedLoader = BundleExerciseLibrarySeedLoader()
        return LocalExerciseLibraryRepository(store: exerciseLibraryStore, seedLoader: seedLoader)
    }()
    
    // MARK: - Use Case Factories
    
    private(set) lazy var workoutsUseCaseFactory: WorkoutsUseCaseFactory = {
        WorkoutsUseCaseFactory(
            workoutRepository: workoutRepository,
            routineRepository: routineRepository,
            exerciseHistoryRepository: exerciseHistoryRepository,
            exerciseHistoryProvider: exerciseHistoryProvider
        )
    }()
    
    private(set) lazy var exerciseLibraryUseCaseFactory: ExerciseLibraryUseCaseFactory = {
        ExerciseLibraryUseCaseFactory(repository: exerciseLibraryRepository)
    }()
    
    private(set) lazy var analyticsUseCaseFactory: AnalyticsUseCaseFactory = {
        AnalyticsUseCaseFactory(
            workoutRepository: workoutRepository,
            exerciseLibraryRepository: exerciseLibraryRepository
        )
    }()
    
    private(set) lazy var progressionUseCaseFactory: ProgressionUseCaseFactory = {
        ProgressionUseCaseFactory(exerciseHistoryRepository: exerciseHistoryRepository)
    }()
    
    // MARK: - Initialization
    
    init() {}
}
