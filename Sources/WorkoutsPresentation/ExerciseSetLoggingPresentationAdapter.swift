import Foundation
import WorkoutsDomain

public final class ExerciseSetLoggingPresentationAdapter {
	private let logging: ExerciseSetLogging
	private let restTimerHandler: RestTimerHandling?
	public var presenter: ExerciseSetLoggingPresenter?
	
	public init(logging: ExerciseSetLogging, restTimerHandler: RestTimerHandling? = nil) {
		self.logging = logging
		self.restTimerHandler = restTimerHandler
	}
	
	public func addSet(to workoutID: UUID, exerciseID: UUID, request: ExerciseSetRequest) {
		presenter?.didStartLogging()
		logging.addSet(to: workoutID, exerciseID: exerciseID, request: request) { [weak self] result in
			switch result {
			case let .success(logResult):
				self?.presenter?.didFinishLogging(with: logResult, action: .added)
				self?.restTimerHandler?.handleSetCompletion(for: exerciseID)
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
				self?.restTimerHandler?.handleSetCompletion(for: exerciseID)
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
