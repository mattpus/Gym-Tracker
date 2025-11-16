import Foundation
import WorkoutsDomain

public final class SaveWorkoutAsRoutinePresentationAdapter {
	private let saver: WorkoutRoutineSaving
	public var presenter: WorkoutCommandPresenter?
	
	public init(saver: WorkoutRoutineSaving) {
		self.saver = saver
	}
	
	public func save(workout: Workout, as routineName: String?) {
		presenter?.didStartCommand()
		
		saver.save(workout: workout, as: routineName) { [weak self] result in
			switch result {
			case .success:
				self?.presenter?.didFinishCommand()
			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
