import Foundation

public final class DeleteWorkoutPresentationAdapter {
	private let deleting: WorkoutDeleting
	public var presenter: WorkoutCommandPresenter?
	
	public init(deleting: WorkoutDeleting) {
		self.deleting = deleting
	}
	
	public func delete(workoutID: UUID) {
		presenter?.didStartCommand()
		
		deleting.delete(workoutID: workoutID) { [weak self] result in
			switch result {
			case .success:
				self?.presenter?.didFinishCommand()
			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
