import Foundation

public final class RoutineBuilderPresenter {
	private let routineBuilderView: RoutineBuilderDisplaying
	private let loadingView: RoutineBuilderLoadingView
	private let errorView: RoutineBuilderErrorView
	private let searchResultsView: RoutineSearchResultsView
	private let createRoutine: RoutineBuilding
	private let reordering: RoutineReordering
	private let exerciseSearch: WorkoutExerciseLibrarySearching
	
	private var routine = Routine(name: "", exercises: [])
	
	public init(
		routineBuilderView: RoutineBuilderDisplaying,
		loadingView: RoutineBuilderLoadingView,
		errorView: RoutineBuilderErrorView,
		searchResultsView: RoutineSearchResultsView,
		createRoutine: RoutineBuilding,
		reordering: RoutineReordering,
		exerciseSearch: WorkoutExerciseLibrarySearching
	) {
		self.routineBuilderView = routineBuilderView
		self.loadingView = loadingView
		self.errorView = errorView
		self.searchResultsView = searchResultsView
		self.createRoutine = createRoutine
		self.reordering = reordering
		self.exerciseSearch = exerciseSearch
	}
	
	public func start() {
		displayBuilder()
	}
	
	public func didUpdateName(_ name: String) {
		routine = Routine(
			id: routine.id,
			name: name,
			notes: routine.notes,
			exercises: routine.exercises
		)
		displayBuilder()
	}
	
	public func didRequestSave() {
		loadingView.display(.init(isLoading: true))
		errorView.display(.init(message: nil))
		
		createRoutine.create(routine) { [weak self] result in
			switch result {
			case .success:
				self?.loadingView.display(.init(isLoading: false))
			case let .failure(error):
				self?.errorView.display(.init(message: self?.localized(error)))
				self?.loadingView.display(.init(isLoading: false))
			}
		}
	}
	
	public func didMoveExercise(from sourceIndex: Int, to destinationIndex: Int) {
		switch reordering.reorderExercises(in: routine, from: sourceIndex, to: destinationIndex) {
		case let .success(updated):
			routine = updated
			displayBuilder()
		case let .failure(error):
			errorView.display(.init(message: localized(error)))
		}
	}
	
	public func didRemoveExercise(at index: Int) {
		guard routine.exercises.indices.contains(index) else { return }
		var exercises = routine.exercises
		exercises.remove(at: index)
		routine = Routine(id: routine.id, name: routine.name, notes: routine.notes, exercises: exercises)
		displayBuilder()
	}
	
	public func didSearchExercises(query: String) {
		exerciseSearch.search(query: query) { [weak self] result in
			switch result {
			case let .success(items):
				self?.searchResultsView.display(.init(items: items.map {
					.init(id: $0.id, name: $0.name, subtitle: $0.primaryMuscle ?? "")
				}))
			case let .failure(error):
				self?.errorView.display(.init(message: self?.localized(error)))
			}
		}
	}
	
	public func didSelectExercise(_ item: ExerciseLibraryItem) {
		let exercise = RoutineExercise(id: item.id, name: item.name, notes: item.primaryMuscle, sets: [])
		routine = Routine(
			id: routine.id,
			name: routine.name,
			notes: routine.notes,
			exercises: routine.exercises + [exercise]
		)
		displayBuilder()
	}
	
	private func displayBuilder() {
		let viewModel = RoutineBuilderScreenViewModel(
			title: "New Routine",
			name: routine.name,
			isSaveEnabled: routine.isValidForSave,
			exercises: routine.exercises.map { exercise in
				.init(
					id: exercise.id,
					name: exercise.name,
					setsSummary: setsSummary(for: exercise)
				)
			}
		)
		routineBuilderView.display(viewModel)
	}
	
	private func setsSummary(for exercise: RoutineExercise) -> String {
		let count = exercise.sets.count
		let unit = count == 1 ? "set" : "sets"
		return count > 0 ? "\(count) \(unit)" : "No sets"
	}
	
	private func localized(_ error: Error) -> String {
		"Something went wrong. Please try again."
	}
}

private extension Routine {
	var isValidForSave: Bool {
		!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !exercises.isEmpty
	}
}
