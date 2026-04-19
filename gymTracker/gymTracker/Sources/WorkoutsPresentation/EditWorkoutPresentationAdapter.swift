import Foundation

public final class EditWorkoutPresentationAdapter {
	private let editing: WorkoutEditing
	public var presenter: WorkoutCommandPresenter?
	
	public init(editing: WorkoutEditing) {
		self.editing = editing
	}
	
	public func edit(_ workout: Workout) {
		presenter?.didStartCommand()
		
		editing.edit(workout) { [weak self] result in
			switch result {
			case .success:
				self?.presenter?.didFinishCommand()
			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
