import Foundation
import Observation

@Observable
@MainActor
final class WorkoutsRouter {
    let navigation: NavigationRouter
    private let container: DependencyContainer

    private var editingFinishedWorkout = false
    private var isStartingWorkout = false
    private var isContentVisible = false
    private var pendingActiveWorkout: Workout?

    private(set) var workoutsListViewModel: WorkoutsListViewModel
    private(set) var activeWorkoutViewModel: ActiveWorkoutViewModel?
    private(set) var exerciseSelectionViewModel: ExerciseSelectionViewModel?
    private(set) var routineBuilderViewModel: RoutineBuilderViewModel?

    init(container: DependencyContainer, navigation: NavigationRouter) {
        self.container = container
        self.navigation = navigation
        self.workoutsListViewModel = WorkoutsListViewModel(
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            deleteWorkoutUseCase: container.workoutsUseCaseFactory.makeDeleteWorkoutUseCase()
        )
    }

    func showWorkoutDetail(workoutId: UUID) {
        navigation.push(.workoutDetail(id: workoutId))
    }

    func showRoutineSelection() {
        navigation.present(sheet: .routineSelection)
    }

    func dismissRoutineSelection() {
        if navigation.presentingSheet == .routineSelection {
            navigation.dismissSheet()
        }
    }

    func showExerciseSelection() {
        exerciseSelectionViewModel = makeExerciseSelectionViewModel()
        navigation.present(sheet: .exerciseSelection(.activeWorkout))
    }

    func dismissExerciseSelection() {
        navigation.dismissSheet()
        exerciseSelectionViewModel = nil
    }

    func showRoutineBuilder() {
        routineBuilderViewModel = makeRoutineBuilderViewModel()
        navigation.present(sheet: .routineBuilder)
    }

    func dismissRoutineBuilder() {
        navigation.dismissSheet()
        routineBuilderViewModel = nil
        exerciseSelectionViewModel = nil
    }

    func showRoutineBuilderExerciseSelection() {
        exerciseSelectionViewModel = makeExerciseSelectionViewModel()
        navigation.present(sheet: .routineBuilderExerciseSelection)
    }

    func dismissRoutineBuilderExerciseSelection() {
        navigation.present(sheet: .routineBuilder)
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
        navigation.dismissSheet()
        routineBuilderViewModel = nil
        exerciseSelectionViewModel = nil
        workoutsListViewModel.loadWorkouts()
    }

    func contentDidAppear() {
        isContentVisible = true

        if let pendingActiveWorkout {
            self.pendingActiveWorkout = nil
            startActiveWorkout(pendingActiveWorkout)
        } else if navigation.presentingFullScreen == nil, activeWorkoutViewModel == nil {
            recoverActiveWorkoutIfNeeded()
        }
    }

    func contentDidDisappear() {
        isContentVisible = false
    }

    func startEmptyWorkout() {
        guard !isStartingWorkout, navigation.presentingFullScreen == nil else { return }
        isStartingWorkout = true

        container.workoutsUseCaseFactory.makeStartEmptyWorkoutUseCase().startEmptyWorkout(named: nil) { [weak self] result in
            Task { @MainActor in
                if case let .success(workout) = result {
                    self?.startActiveWorkout(workout)
                } else {
                    self?.isStartingWorkout = false
                }
            }
        }
    }

    func startWorkoutFromRoutine(_ routine: Routine) {
        guard !isStartingWorkout, navigation.presentingFullScreen == nil else { return }
        isStartingWorkout = true

        container.workoutsUseCaseFactory.makeStartRoutineUseCase().startRoutine(id: routine.id) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let workout):
                    self?.startActiveWorkout(workout)
                    self?.workoutsListViewModel.loadWorkouts()
                case .failure:
                    self?.isStartingWorkout = false
                }
            }
        }
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

    func finishActiveWorkout(_ workoutId: UUID) {
        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(workoutID: workoutId, at: Date()) { [weak self] _ in
            Task { @MainActor in
                self?.navigation.dismissFullScreen()
                self?.activeWorkoutViewModel?.cleanup()
                self?.activeWorkoutViewModel = nil
                self?.editingFinishedWorkout = false
                self?.exerciseSelectionViewModel = nil
                self?.navigation.dismissSheet()
                self?.workoutsListViewModel.loadWorkouts()
            }
        }
    }

    func saveActiveWorkoutAsRoutine(named name: String?) {
        guard let workout = activeWorkoutViewModel?.workout else { return }
        container.workoutsUseCaseFactory.makeSaveWorkoutAsRoutineUseCase().save(workout: workout, as: name) { _ in }
    }

    func cancelActiveWorkout(_ workoutId: UUID) {
        if editingFinishedWorkout {
            clearActiveWorkoutPresentation()
            editingFinishedWorkout = false
            return
        }

        container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().discard(workoutID: workoutId) { [weak self] _ in
            Task { @MainActor in
                self?.clearActiveWorkoutPresentation()
                self?.editingFinishedWorkout = false
            }
        }
    }

    private func startActiveWorkout(_ workout: Workout) {
        activeWorkoutViewModel = makeActiveWorkoutViewModel(workout: workout, isEditingFinishedWorkout: editingFinishedWorkout)
        presentActiveWorkoutCover(id: workout.id)
    }

    private func presentActiveWorkoutCover(id: UUID) {
        guard isContentVisible else {
            pendingActiveWorkout = activeWorkoutViewModel?.workout
            return
        }

        if navigation.presentingSheet != nil {
            navigation.dismissSheet()
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(350))
                self?.presentActiveWorkoutCover(id: id)
            }
            return
        }

        navigation.present(fullScreen: .activeWorkout(id: id))
        isStartingWorkout = false
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
                container.workoutsUseCaseFactory.makeFinishWorkoutUseCase().finish(
                    workoutID: activeWorkout.id,
                    at: activeWorkout.lastUpdatedAt.addingTimeInterval(twoHours)
                ) { [weak self] _ in
                    Task { @MainActor in
                        self?.workoutsListViewModel.loadWorkouts()
                    }
                }
            } else {
                startActiveWorkout(activeWorkout)
            }
        } catch {
            return
        }
    }

    private func clearActiveWorkoutPresentation() {
        navigation.dismissFullScreen()
        activeWorkoutViewModel?.cleanup()
        activeWorkoutViewModel = nil
        exerciseSelectionViewModel = nil
        navigation.dismissSheet()
    }

    func makeWorkoutDetailViewModel(workoutId: UUID) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(
            workoutId: workoutId,
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            calculateStatisticsUseCase: container.workoutsUseCaseFactory.makeCalculateWorkoutStatisticsUseCase()
        )
    }

    func makeRoutineSelectionViewModel() -> RoutineSelectionViewModel {
        RoutineSelectionViewModel(loadRoutinesUseCase: container.workoutsUseCaseFactory.makeLoadRoutinesUseCase())
    }

    func makeExerciseSelectionViewModel() -> ExerciseSelectionViewModel {
        ExerciseSelectionViewModel(
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase(),
            searchExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeSearchExerciseLibraryUseCase()
        )
    }

    func makeRoutineBuilderViewModel() -> RoutineBuilderViewModel {
        RoutineBuilderViewModel(createRoutineUseCase: container.workoutsUseCaseFactory.makeCreateRoutineUseCase())
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
