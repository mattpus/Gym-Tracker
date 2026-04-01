import SwiftUI
import WorkoutsDomain

/// Coordinator for the Workouts tab - handles workout listing, detail, and active workout flows
@Observable
@MainActor
final class WorkoutsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var path: [WorkoutsRoute] = []
    var sheet: WorkoutsSheet?
    var cover: WorkoutsCover?
    
    private let container: DependencyContainer
    
    // View Models (lazy loaded)
    private(set) var workoutsListViewModel: WorkoutsListViewModel?
    private(set) var activeWorkoutViewModel: ActiveWorkoutViewModel?
    private(set) var exerciseSelectionViewModel: ExerciseSelectionViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        workoutsListViewModel = makeWorkoutsListViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        WorkoutsCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func destinationView(for route: WorkoutsRoute) -> some View {
        switch route {
        case .workoutDetail(let id):
            WorkoutDetailView(
                viewModel: makeWorkoutDetailViewModel(workoutId: id),
                coordinator: self
            )
        }
    }
    
    @ViewBuilder
    func sheetView(for sheet: WorkoutsSheet) -> some View {
        switch sheet {
        case .routineSelection:
            RoutineSelectionView(
                viewModel: makeRoutineSelectionViewModel(),
                coordinator: self
            )
        case .exerciseSelection:
            ExerciseSelectionSheetContent(coordinator: self)
        }
    }
    
    @ViewBuilder
    func coverView(for cover: WorkoutsCover) -> some View {
        switch cover {
        case .activeWorkout:
            if let viewModel = activeWorkoutViewModel {
                ActiveWorkoutView(viewModel: viewModel, coordinator: self)
            }
        }
    }
    
    func makeRoutineSelectionViewModel() -> RoutineSelectionViewModel {
        RoutineSelectionViewModel(
            loadRoutinesUseCase: container.workoutsUseCaseFactory.makeLoadRoutinesUseCase()
        )
    }
    
    func makeExerciseSelectionViewModel() -> ExerciseSelectionViewModel {
        ExerciseSelectionViewModel(
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase(),
            searchExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeSearchExerciseLibraryUseCase()
        )
    }
    
    // MARK: - Navigation Actions
    
    func showWorkoutDetail(workoutId: UUID) {
        path.append(.workoutDetail(id: workoutId))
    }
    
    func showRoutineSelection() {
        sheet = .routineSelection
    }
    
    func dismissRoutineSelection() {
        if sheet == .routineSelection {
            sheet = nil
        }
    }
    
    func showExerciseSelection() {
        exerciseSelectionViewModel = makeExerciseSelectionViewModel()
        sheet = .exerciseSelection
    }
    
    func dismissExerciseSelection() {
        if sheet == .exerciseSelection {
            sheet = nil
        }
        exerciseSelectionViewModel = nil
    }
    
    func addExerciseToActiveWorkout(_ exercise: Exercise) {
        activeWorkoutViewModel?.addExercise(exercise)
        dismissExerciseSelection()
    }
    
    func startEmptyWorkout() {
        // Create a new empty workout and schedule it
        let newWorkout = Workout(
            id: UUID(),
            date: Date(),
            name: "Untitled Workout",
            exercises: []
        )
        
        container.workoutsUseCaseFactory.makeScheduleWorkoutUseCase().schedule(newWorkout) { [weak self] result in
            Task { @MainActor in
                if case .success = result {
                    self?.startActiveWorkout(newWorkout)
                }
            }
        }
    }
    
    func startWorkoutFromRoutine(_ routine: Routine) {
        container.workoutsUseCaseFactory.makeStartRoutineUseCase().startRoutine(id: routine.id) { [weak self] result in
            Task { @MainActor in
                if case .success = result {
                    self?.dismissRoutineSelection()
                    // Load workouts to get the newly created workout
                    self?.workoutsListViewModel?.loadWorkouts()
                    // For now, just show the workout list - could be improved
                }
            }
        }
    }
    
    private func startActiveWorkout(_ workout: Workout) {
        activeWorkoutViewModel = makeActiveWorkoutViewModel(workout: workout)
        cover = .activeWorkout(id: workout.id)
    }
    
    func finishActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(workoutID: workoutId, at: Date()) { [weak self] result in
            Task { @MainActor in
                self?.cover = nil
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.exerciseSelectionViewModel = nil
                self?.sheet = nil
                self?.workoutsListViewModel?.loadWorkouts()
            }
        }
    }
    
    func cancelActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().discard(workoutID: workoutId) { [weak self] _ in
            Task { @MainActor in
                self?.cover = nil
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.exerciseSelectionViewModel = nil
                self?.sheet = nil
            }
        }
    }
    
    // MARK: - ViewModel Factories
    
    private func makeWorkoutsListViewModel() -> WorkoutsListViewModel {
        WorkoutsListViewModel(
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            deleteWorkoutUseCase: container.workoutsUseCaseFactory.makeDeleteWorkoutUseCase()
        )
    }
    
    private func makeWorkoutDetailViewModel(workoutId: UUID) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(
            workoutId: workoutId,
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            calculateStatisticsUseCase: container.workoutsUseCaseFactory.makeCalculateWorkoutStatisticsUseCase()
        )
    }
    
    private func makeActiveWorkoutViewModel(workout: Workout) -> ActiveWorkoutViewModel {
        ActiveWorkoutViewModel(
            workout: workout,
            exerciseSetLoggingUseCase: container.workoutsUseCaseFactory.makeExerciseSetLoggingUseCase(),
            updateNotesUseCase: container.workoutsUseCaseFactory.makeUpdateExerciseNotesUseCase()
        )
    }
}

/// Navigation destinations for the Workouts flow
enum WorkoutsRoute: Hashable {
    case workoutDetail(id: UUID)
}

enum WorkoutsSheet: String, Identifiable {
    case routineSelection
    case exerciseSelection
    
    var id: String { rawValue }
}

enum WorkoutsCover: Identifiable, Equatable {
    case activeWorkout(id: UUID)
    
    var id: UUID {
        switch self {
        case .activeWorkout(let id):
            return id
        }
    }
}

/// Internal content view that uses @Bindable for navigation
private struct WorkoutsCoordinatorContentView: View {
    @Bindable var coordinator: WorkoutsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            if let viewModel = coordinator.workoutsListViewModel {
                WorkoutsListView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: WorkoutsRoute.self) { route in
                        coordinator.destinationView(for: route)
                    }
            }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            coordinator.sheetView(for: sheet)
        }
        .fullScreenCover(item: $coordinator.cover) { cover in
            coordinator.coverView(for: cover)
        }
    }
}

private struct ExerciseSelectionSheetContent: View {
    @Bindable var coordinator: WorkoutsCoordinator
    
    var body: some View {
        if let viewModel = coordinator.exerciseSelectionViewModel {
            ExerciseSelectionView(
                viewModel: viewModel,
                onExerciseSelected: { exercise in
                    coordinator.addExerciseToActiveWorkout(exercise)
                }
            )
        } else {
            ContentUnavailableView {
                Label("No Exercise Selection", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Unable to load the exercise selector.")
            }
        }
    }
}

/// View wrapper for WorkoutsCoordinator
struct WorkoutsCoordinatorView: View {
    let coordinator: WorkoutsCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
