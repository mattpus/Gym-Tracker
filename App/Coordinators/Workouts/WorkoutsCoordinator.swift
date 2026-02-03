import SwiftUI
import WorkoutsDomain

/// Coordinator for the Workouts tab - handles workout listing, detail, and active workout flows
@Observable
@MainActor
final class WorkoutsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    // Sheet presentation states
    var showingRoutineSelection = false
    var showingExerciseSelection = false
    var showingActiveWorkout = false
    
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
    func destinationView(for destination: WorkoutsDestination) -> some View {
        switch destination {
        case .workoutDetail(let id):
            WorkoutDetailView(
                viewModel: makeWorkoutDetailViewModel(workoutId: id),
                coordinator: self
            )
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
        navigationPath.append(WorkoutsDestination.workoutDetail(id: workoutId))
    }
    
    func showRoutineSelection() {
        showingRoutineSelection = true
    }
    
    func dismissRoutineSelection() {
        showingRoutineSelection = false
    }
    
    func showExerciseSelection() {
        exerciseSelectionViewModel = makeExerciseSelectionViewModel()
        showingExerciseSelection = true
    }
    
    func dismissExerciseSelection() {
        showingExerciseSelection = false
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
        showingActiveWorkout = true
    }
    
    func finishActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(workoutID: workoutId, at: Date()) { [weak self] result in
            Task { @MainActor in
                self?.showingActiveWorkout = false
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.workoutsListViewModel?.loadWorkouts()
            }
        }
    }
    
    func cancelActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().discard(workoutID: workoutId) { [weak self] _ in
            Task { @MainActor in
                self?.showingActiveWorkout = false
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
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
enum WorkoutsDestination: Hashable {
    case workoutDetail(id: UUID)
}

/// Internal content view that uses @Bindable for navigation
private struct WorkoutsCoordinatorContentView: View {
    @Bindable var coordinator: WorkoutsCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.workoutsListViewModel {
                WorkoutsListView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: WorkoutsDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
        .sheet(isPresented: $coordinator.showingRoutineSelection) {
            RoutineSelectionView(
                viewModel: coordinator.makeRoutineSelectionViewModel(),
                coordinator: coordinator
            )
        }
        .sheet(isPresented: $coordinator.showingExerciseSelection) {
            if let viewModel = coordinator.exerciseSelectionViewModel {
                ExerciseSelectionView(
                    viewModel: viewModel,
                    onExerciseSelected: { exercise in
                        coordinator.addExerciseToActiveWorkout(exercise)
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $coordinator.showingActiveWorkout) {
            if let viewModel = coordinator.activeWorkoutViewModel {
                ActiveWorkoutView(viewModel: viewModel, coordinator: coordinator)
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
