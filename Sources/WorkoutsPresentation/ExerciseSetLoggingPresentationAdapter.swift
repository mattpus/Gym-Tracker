import Foundation
import WorkoutsDomain

public final class ExerciseSetLoggingPresentationAdapter {
	private let logging: ExerciseSetLogging
	public var presenter: ExerciseSetLoggingPresenter?
	
	public init(logging: ExerciseSetLogging) {
		self.logging = logging
	}
	
	public func addSet(to workoutID: UUID, exerciseID: UUID, request: ExerciseSetRequest) {
		presenter?.didStartLogging()
		logging.addSet(to: workoutID, exerciseID: exerciseID, request: request) { [weak self] result in
			switch result {
			case let .success(logResult):
				self?.presenter?.didFinishLogging(with: logResult, action: .added)
			case let .failure(error):
				self?.presenter?.didFinish(with: error)
			}
		}
	}
	
	public func updateSet(in workoutID: UUID, exerciseID: UUID, setID: UUID, request: ExerciseSetRequest) {
		presenter?.didStartLogging()
		logging.updateSet(in: workoutID, exerciseID: exerciseID, setID: setID, request: request) { [weak self] result in
			switch result {
			case let .success(logResult):
				self?.presenter?.didFinishLogging(with: logResult, action: .updated)
			case let .failure(error):
				self?.presenter?.didFinish(with: error)
			}
		}
	}
	
	public func deleteSet(in workoutID: UUID, exerciseID: UUID, setID: UUID) {
		presenter?.didStartLogging()
		logging.deleteSet(in: workoutID, exerciseID: exerciseID, setID: setID) { [weak self] result in
			switch result {
			case let .success(deletionResult):
				self?.presenter?.didFinishDeleting(with: deletionResult)
			case let .failure(error):
				self?.presenter?.didFinish(with: error)
			}
		}
	}
}
