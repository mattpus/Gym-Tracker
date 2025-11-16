import Foundation
import WorkoutsDomain

public protocol RemoveExerciseView: AnyObject {
	func displayConfirmation(message: String, confirm: @escaping () -> Void)
}

public final class RemoveExercisePresenter {
	private let view: RemoveExerciseView
	private let removing: WorkoutExerciseRemoving
	private let commandPresenter: WorkoutCommandPresenter
	public var onUpdatedWorkout: ((Workout) -> Void)?

	public init(view: RemoveExerciseView, removing: WorkoutExerciseRemoving, commandPresenter: WorkoutCommandPresenter) {
		self.view = view
		self.removing = removing
		self.commandPresenter = commandPresenter
	}

	public func confirmRemoval(workoutID: UUID, exerciseID: UUID) {
		let message = "Removing this exercise will delete its sets. Continue?"
		view.displayConfirmation(message: message) { [weak self] in
			self?.remove(workoutID: workoutID, exerciseID: exerciseID)
		}
	}

	private func remove(workoutID: UUID, exerciseID: UUID) {
		commandPresenter.didStartCommand()
		removing.removeExercise(in: workoutID, exerciseID: exerciseID) { [weak self] result in
			switch result {
			case let .success(workout):
				self?.onUpdatedWorkout?(workout)
				self?.commandPresenter.didFinishCommand()
			case let .failure(error):
				self?.commandPresenter.didFinishCommand(with: error)
			}
		}
	}
}
