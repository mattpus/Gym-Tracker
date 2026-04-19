import SwiftUI
import Observation

/// Coordinator for the Workouts tab - handles workout listing, detail, and active workout flows
@Observable
@MainActor
final class WorkoutsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var path: [WorkoutsRoute] = []
    var sheet: WorkoutsSheet?
    var cover: WorkoutsCover?
    private var editingFinishedWorkout = false
    
    private let container: DependencyContainer
    
    // View Models (lazy loaded)
    private(set) var workoutsListViewModel: WorkoutsListViewModel?
    private(set) var activeWorkoutViewModel: ActiveWorkoutViewModel?
    private(set) var exerciseSelectionViewModel: ExerciseSelectionViewModel?
    private(set) var routineBuilderViewModel: RoutineBuilderViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        workoutsListViewModel = makeWorkoutsListViewModel()
        recoverActiveWorkoutIfNeeded()
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
        case .routineBuilder:
            if let viewModel = routineBuilderViewModel {
                RoutineBuilderView(viewModel: viewModel, coordinator: self)
            }
        case .routineBuilderExerciseSelection:
            RoutineBuilderExerciseSelectionSheetContent(coordinator: self)
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
    
    func makeRoutineBuilderViewModel() -> RoutineBuilderViewModel {
        RoutineBuilderViewModel(
            createRoutineUseCase: container.workoutsUseCaseFactory.makeCreateRoutineUseCase()
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
    
    func showRoutineBuilder() {
        routineBuilderViewModel = makeRoutineBuilderViewModel()
        sheet = .routineBuilder
    }
    
    func dismissRoutineBuilder() {
        if sheet == .routineBuilder || sheet == .routineBuilderExerciseSelection {
            sheet = nil
        }
        routineBuilderViewModel = nil
        exerciseSelectionViewModel = nil
    }
    
    func showRoutineBuilderExerciseSelection() {
        exerciseSelectionViewModel = makeExerciseSelectionViewModel()
        sheet = .routineBuilderExerciseSelection
    }
    
    func dismissRoutineBuilderExerciseSelection() {
        if sheet == .routineBuilderExerciseSelection {
            sheet = .routineBuilder
        }
        exerciseSelectionViewModel = nil
    }
    
    func addExerciseToActiveWorkout(_ exercise: Exercise) {
        activeWorkoutViewModel?.addExercise(exercise)
        dismissExerciseSelection()
    }
    
    func addExerciseToRoutineBuilder(_ exercise: Exercise) {
        let item = SelectableExerciseItem(
            id: exercise.id,
            name: exercise.name,
            primaryMuscleGroup: .chest,
            secondaryMuscleGroups: [],
            equipmentType: .barbell,
            isCustom: false
        )
        routineBuilderViewModel?.addExercise(item)
        dismissRoutineBuilderExerciseSelection()
    }
    
    func didSaveRoutine() {
        sheet = nil
        routineBuilderViewModel = nil
        exerciseSelectionViewModel = nil
    }
    
    func startEmptyWorkout() {
        container.workoutsUseCaseFactory.makeStartEmptyWorkoutUseCase().startEmptyWorkout(named: nil) { [weak self] result in
            Task { @MainActor in
                if case let .success(workout) = result {
                    self?.startActiveWorkout(workout)
                }
            }
        }
    }
    
    func startWorkoutFromRoutine(_ routine: Routine) {
        container.workoutsUseCaseFactory.makeStartRoutineUseCase().startRoutine(id: routine.id) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let workout):
                    self?.dismissRoutineSelection()
                    self?.startActiveWorkout(workout)
                    self?.workoutsListViewModel?.loadWorkouts()
                case .failure:
                    break
                }
            }
        }
    }
    
    private func startActiveWorkout(_ workout: Workout) {
        activeWorkoutViewModel = makeActiveWorkoutViewModel(workout: workout, isEditingFinishedWorkout: editingFinishedWorkout)
        cover = .activeWorkout(id: workout.id)
    }

    func editFinishedWorkout(workoutId: UUID) {
        do {
            guard let workout = try container.workoutRepository.loadWorkouts().first(where: { $0.id == workoutId }) else {
                return
            }

            editingFinishedWorkout = true
            startActiveWorkout(workout)
        } catch {
            return
        }
    }

    private func recoverActiveWorkoutIfNeeded() {
        do {
            let workouts = try container.workoutRepository.loadWorkouts()
            guard let activeWorkout = workouts
                .filter({ !$0.isFinished })
                .sorted(by: { $0.lastUpdatedAt > $1.lastUpdatedAt })
                .first else {
                return
            }

            let twoHours: TimeInterval = 2 * 60 * 60
            if Date().timeIntervalSince(activeWorkout.lastUpdatedAt) >= twoHours {
                container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(workoutID: activeWorkout.id, at: activeWorkout.lastUpdatedAt.addingTimeInterval(twoHours)) { [weak self] _ in
                    Task { @MainActor in
                        self?.workoutsListViewModel?.loadWorkouts()
                    }
                }
            } else {
                startActiveWorkout(activeWorkout)
            }
        } catch {
            return
        }
    }
    
    func finishActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(workoutID: workoutId, at: Date()) { [weak self] result in
            Task { @MainActor in
                self?.cover = nil
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.editingFinishedWorkout = false
                self?.exerciseSelectionViewModel = nil
                self?.sheet = nil
                self?.workoutsListViewModel?.loadWorkouts()
            }
        }
    }
    
    func saveActiveWorkoutAsRoutine(named name: String?) {
        guard let workout = activeWorkoutViewModel?.workout else { return }
        container.workoutsUseCaseFactory.makeSaveWorkoutAsRoutineUseCase().save(workout: workout, as: name) { _ in }
    }
    
    func cancelActiveWorkout(_ workoutId: UUID) {
        if editingFinishedWorkout {
            cover = nil
            activeWorkoutViewModel?.cleanup()
            activeWorkoutViewModel = nil
            exerciseSelectionViewModel = nil
            sheet = nil
            editingFinishedWorkout = false
            return
        }

        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().discard(workoutID: workoutId) { [weak self] _ in
            Task { @MainActor in
                self?.cover = nil
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.exerciseSelectionViewModel = nil
                self?.sheet = nil
                self?.editingFinishedWorkout = false
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
    
    private func makeActiveWorkoutViewModel(workout: Workout, isEditingFinishedWorkout: Bool = false) -> ActiveWorkoutViewModel {
        ActiveWorkoutViewModel(
            workout: workout,
            exerciseSetLoggingUseCase: container.workoutsUseCaseFactory.makeExerciseSetLoggingUseCase(),
            updateNotesUseCase: container.workoutsUseCaseFactory.makeUpdateExerciseNotesUseCase(),
            editWorkoutUseCase: container.workoutsUseCaseFactory.makeEditWorkoutUseCase(),
            isEditingFinishedWorkout: isEditingFinishedWorkout
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
    case routineBuilder
    case routineBuilderExerciseSelection
    
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

private struct RoutineBuilderExerciseSelectionSheetContent: View {
    @Bindable var coordinator: WorkoutsCoordinator
    
    var body: some View {
        if let viewModel = coordinator.exerciseSelectionViewModel {
            ExerciseSelectionView(
                viewModel: viewModel,
                onExerciseSelected: { exercise in
                    coordinator.addExerciseToRoutineBuilder(exercise)
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
