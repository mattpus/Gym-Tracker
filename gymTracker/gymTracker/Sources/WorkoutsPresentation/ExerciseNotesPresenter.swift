import Foundation

public final class ExerciseNotesPresenter {
	private let view: ExerciseNotesView
	private let commandPresenter: WorkoutCommandPresenter
	private let placeholder: String
	public var onUpdatedWorkout: ((Workout) -> Void)?

	public init(
		view: ExerciseNotesView,
		commandPresenter: WorkoutCommandPresenter,
		placeholder: String = "Add notes"
	) {
		self.view = view
		self.commandPresenter = commandPresenter
		self.placeholder = placeholder
	}

	public func presentNotes(for exercise: Exercise) {
		view.display(.init(exerciseID: exercise.id, notes: exercise.notes ?? "", placeholder: placeholder))
	}

	public func didStartUpdatingNotes() {
		commandPresenter.didStartCommand()
	}

	public func didFinishUpdatingNotes(with workout: Workout, exerciseID: UUID) {
		onUpdatedWorkout?(workout)
		let text = workout.exercises.first(where: { $0.id == exerciseID })?.notes ?? ""
		view.display(.init(exerciseID: exerciseID, notes: text, placeholder: placeholder))
		commandPresenter.didFinishCommand()
	}

	public func didFinish(with error: Swift.Error) {
		commandPresenter.didFinishCommand(with: error)
	}
}
