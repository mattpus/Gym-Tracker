import Foundation
import WorkoutsDomain

public final class StartEmptyWorkoutPresentationAdapter {
	private let starter: EmptyWorkoutStarting
	public var presenter: WorkoutCommandPresenter?
	
	public init(starter: EmptyWorkoutStarting) {
		self.starter = starter
	}
	
	public func start(name: String?) {
		presenter?.didStartCommand()
		
		starter.startEmptyWorkout(named: name) { [weak self] result in
			switch result {
			case .success(_):
				self?.presenter?.didFinishCommand()
			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
