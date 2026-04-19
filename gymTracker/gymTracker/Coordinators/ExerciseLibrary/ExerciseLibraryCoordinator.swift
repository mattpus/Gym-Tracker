import SwiftUI
import Observation

/// Coordinator for the Exercise Library - accessible from workout flows
@Observable
@MainActor
final class ExerciseLibraryCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    var showingAddCustomExercise = false
    var editingExercise: LibraryExerciseItem?
    
    private let container: DependencyContainer
    private(set) var exerciseLibraryViewModel: ExerciseLibraryViewModel?
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() {
        exerciseLibraryViewModel = makeExerciseLibraryViewModel()
    }
    
    @ViewBuilder
    func rootView() -> some View {
        ExerciseLibraryCoordinatorContentView(coordinator: self)
    }
    
    @ViewBuilder
    func destinationView(for destination: ExerciseLibraryDestination) -> some View {
        switch destination {
        case .exerciseDetail(let id):
            ExerciseDetailView(
                viewModel: makeExerciseDetailViewModel(exerciseId: id),
                coordinator: self
            )
        }
    }
    
    // MARK: - Navigation Actions
    
    func showExerciseDetail(exerciseId: UUID) {
        navigationPath.append(ExerciseLibraryDestination.exerciseDetail(id: exerciseId))
    }
    
    func showAddCustomExercise() {
        showingAddCustomExercise = true
    }

    func showEditCustomExercise(_ exercise: LibraryExerciseItem) {
        editingExercise = exercise
    }
    
    func dismissAddCustomExercise() {
        showingAddCustomExercise = false
        exerciseLibraryViewModel?.loadExercises()
    }

    func dismissEditCustomExercise() {
        editingExercise = nil
        exerciseLibraryViewModel?.loadExercises()
    }

    func deleteCustomExercise(_ exerciseId: UUID) {
        do {
            try container.exerciseLibraryUseCaseFactory.makeDeleteCustomExerciseUseCase().delete(exerciseId: exerciseId)
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
            exerciseLibraryViewModel?.loadExercises()
        } catch {
            return
        }
    }
    
    // MARK: - ViewModel Factories
    
    private func makeExerciseLibraryViewModel() -> ExerciseLibraryViewModel {
        ExerciseLibraryViewModel(
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase(),
            searchExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeSearchExerciseLibraryUseCase()
        )
    }
    
    private func makeExerciseDetailViewModel(exerciseId: UUID) -> ExerciseDetailViewModel {
        ExerciseDetailViewModel(
            exerciseId: exerciseId,
            loadExerciseLibraryUseCase: container.exerciseLibraryUseCaseFactory.makeLoadExerciseLibraryUseCase()
        )
    }
    
    func makeAddCustomExerciseViewModel() -> AddCustomExerciseViewModel {
        AddCustomExerciseViewModel(
            addCustomExerciseUseCase: container.exerciseLibraryUseCaseFactory.makeAddCustomExerciseUseCase()
        )
    }

    func makeEditCustomExerciseViewModel(exercise: LibraryExerciseItem) -> EditCustomExerciseViewModel {
        EditCustomExerciseViewModel(
            exercise: exercise,
            editCustomExerciseUseCase: container.exerciseLibraryUseCaseFactory.makeEditCustomExerciseUseCase()
        )
    }
}

/// Navigation destinations for the Exercise Library flow
enum ExerciseLibraryDestination: Hashable {
    case exerciseDetail(id: UUID)
}

/// Internal content view that uses @Bindable for navigation
private struct ExerciseLibraryCoordinatorContentView: View {
    @Bindable var coordinator: ExerciseLibraryCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            if let viewModel = coordinator.exerciseLibraryViewModel {
                ExerciseLibraryView(viewModel: viewModel, coordinator: coordinator)
                    .navigationDestination(for: ExerciseLibraryDestination.self) { destination in
                        coordinator.destinationView(for: destination)
                    }
            }
        }
        .sheet(isPresented: $coordinator.showingAddCustomExercise) {
            AddCustomExerciseView(
                viewModel: coordinator.makeAddCustomExerciseViewModel(),
                coordinator: coordinator
            )
        }
        .sheet(item: $coordinator.editingExercise) { exercise in
            EditCustomExerciseView(
                viewModel: coordinator.makeEditCustomExerciseViewModel(exercise: exercise),
                coordinator: coordinator
            )
        }
    }
}

/// View wrapper for ExerciseLibraryCoordinator
struct ExerciseLibraryCoordinatorView: View {
    let coordinator: ExerciseLibraryCoordinator
    
    var body: some View {
        coordinator.rootView()
    }
}
