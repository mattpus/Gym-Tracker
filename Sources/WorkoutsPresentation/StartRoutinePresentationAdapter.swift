import Foundation
import WorkoutsDomain

public final class StartRoutinePresentationAdapter {
	private let startRoutine: RoutineStarting
	public var presenter: WorkoutCommandPresenter?
	
	public init(startRoutine: RoutineStarting) {
		self.startRoutine = startRoutine
	}
	
	public func startRoutine(withID routineID: UUID) {
		presenter?.didStartCommand()
		
		startRoutine.startRoutine(id: routineID) { [weak self] result in
			switch result {
			case .success(_):
				self?.presenter?.didFinishCommand()
				
			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
