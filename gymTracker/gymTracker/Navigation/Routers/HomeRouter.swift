import Foundation
import Observation

@Observable
@MainActor
final class HomeRouter {
    let navigation: NavigationRouter
    private let container: DependencyContainer
    private(set) var homeViewModel: HomeViewModel
    private(set) var exerciseLibraryViewModel: ExerciseLibraryViewModel
    var editingExercise: LibraryExerciseItem?

    weak var mainRouter: MainRouter?

    init(container: DependencyContainer, navigation: NavigationRouter) {
        self.container = container
        self.navigation = navigation
        self.homeViewModel = HomeViewModel(
            loadWorkoutsUseCase: container.workoutsUseCaseFactory.makeLoadWorkoutsUseCase(),
            workoutFrequencyUseCase: container.analyticsUseCaseFactory.makeWorkoutFrequencyUseCase()
        )
        self.exerciseLibraryViewModel = ExerciseLibraryViewModel(
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase(),
            searchExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeSearchExerciseLibraryUseCase()
        )
    }

    func showWorkouts() {
        mainRouter?.selectedTab = .workouts
    }

    func startWorkout() {
        mainRouter?.selectedTab = .workouts
        mainRouter?.workoutsRouter.startEmptyWorkout()
    }

    func showWorkoutDetail(_ workoutId: UUID) {
        mainRouter?.selectedTab = .workouts
        mainRouter?.workoutsRouter.showWorkoutDetail(workoutId: workoutId)
    }

    func showExerciseLibrary() {
        navigation.push(.exerciseLibrary)
    }

    func showExerciseDetail(exerciseId: UUID) {
        navigation.push(.exerciseDetail(id: exerciseId))
    }

    func showAddCustomExercise() {
        navigation.present(sheet: .addCustomExercise)
    }

    func showEditCustomExercise(_ exercise: LibraryExerciseItem) {
        editingExercise = exercise
        navigation.present(sheet: .editCustomExercise(id: exercise.id))
    }

    func dismissAddCustomExercise() {
        navigation.dismissSheet()
        exerciseLibraryViewModel.loadExercises()
    }

    func dismissEditCustomExercise() {
        editingExercise = nil
        navigation.dismissSheet()
        exerciseLibraryViewModel.loadExercises()
    }

    func deleteCustomExercise(_ exerciseId: UUID) {
        do {
            try container.exerciseLibraryUseCaseFactory.makeDeleteCustomExerciseUseCase().delete(exerciseId: exerciseId)
            if !navigation.path.isEmpty {
                navigation.path.removeLast()
            }
            exerciseLibraryViewModel.loadExercises()
        } catch {
            return
        }
    }

    func makeExerciseDetailViewModel(exerciseId: UUID) -> ExerciseDetailViewModel {
        ExerciseDetailViewModel(
            exerciseId: exerciseId,
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase()
        )
    }

    func makeAddCustomExerciseViewModel() -> AddCustomExerciseViewModel {
        AddCustomExerciseViewModel(addCustomExerciseUseCase: container.exerciseLibraryUseCaseFactory.makeAddCustomExerciseUseCase())
    }

    func makeEditCustomExerciseViewModel(exercise: LibraryExerciseItem) -> EditCustomExerciseViewModel {
        EditCustomExerciseViewModel(
            exercise: exercise,
            editCustomExerciseUseCase: container.exerciseLibraryUseCaseFactory.makeEditCustomExerciseUseCase()
        )
    }
}
