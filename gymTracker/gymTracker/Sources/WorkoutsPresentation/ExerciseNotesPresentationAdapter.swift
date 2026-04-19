import Foundation

@MainActor
public final class ExerciseNotesPresentationAdapter {
	private let updating: ExerciseNotesUpdating
	public var presenter: ExerciseNotesPresenter?

	public init(updating: ExerciseNotesUpdating) {
		self.updating = updating
	}

	public func updateNotes(in workoutID: UUID, exerciseID: UUID, notes: String?) {
		presenter?.didStartUpdatingNotes()
		updating.updateNotes(in: workoutID, exerciseID: exerciseID, notes: notes) { [weak self] result in
			switch result {
			case let .success(workout):
				self?.presenter?.didFinishUpdatingNotes(with: workout, exerciseID: exerciseID)
			case let .failure(error):
				self?.presenter?.didFinish(with: error)
			}
		}
	}
}
