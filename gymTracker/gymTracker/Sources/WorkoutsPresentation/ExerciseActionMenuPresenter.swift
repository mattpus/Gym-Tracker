import Foundation

public final class ExerciseActionMenuPresenter {
	private let view: ExerciseActionMenuView
	private var context: (workoutID: UUID, exercise: Exercise)?

	public var onReorderRequested: ((UUID, UUID) -> Void)?
	public var onReplaceRequested: ((UUID, UUID) -> Void)?
	public var onRemoveFromSupersetRequested: ((UUID, UUID) -> Void)?
	public var onRemoveRequested: ((UUID, UUID) -> Void)?

	public init(view: ExerciseActionMenuView) {
		self.view = view
	}

	public func presentMenu(for workoutID: UUID, exercise: Exercise) {
		context = (workoutID, exercise)
		view.display(.init(exerciseID: exercise.id, items: items(for: exercise)))
	}

	public func select(_ action: ExerciseActionMenuItemViewModel.Action) {
		guard let context else { return }
		switch action {
		case .reorder:
			onReorderRequested?(context.workoutID, context.exercise.id)
		case .replace:
			onReplaceRequested?(context.workoutID, context.exercise.id)
		case .removeFromSuperset:
			guard context.exercise.supersetID != nil else { return }
			onRemoveFromSupersetRequested?(context.workoutID, context.exercise.id)
		case .removeExercise:
			onRemoveRequested?(context.workoutID, context.exercise.id)
		}
	}

	private func items(for exercise: Exercise) -> [ExerciseActionMenuItemViewModel] {
		[
			ExerciseActionMenuItemViewModel(action: .reorder, title: "Reorder", isEnabled: true),
			ExerciseActionMenuItemViewModel(action: .replace, title: "Replace", isEnabled: true),
			ExerciseActionMenuItemViewModel(
				action: .removeFromSuperset,
				title: "Remove from Superset",
				isEnabled: exercise.supersetID != nil
			),
			ExerciseActionMenuItemViewModel(action: .removeExercise, title: "Remove Exercise", isEnabled: true)
		]
	}
}
