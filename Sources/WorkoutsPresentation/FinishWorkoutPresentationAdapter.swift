import Foundation
import WorkoutsDomain

public final class FinishWorkoutPresentationAdapter {
	private let finisher: WorkoutFinishing
	private let saveRoutineHandler: ((Workout, String?) -> Void)?
	public var presenter: FinishWorkoutPresenter?
	
	public init(finisher: WorkoutFinishing, saveRoutineHandler: ((Workout, String?) -> Void)? = nil) {
		self.finisher = finisher
		self.saveRoutineHandler = saveRoutineHandler
	}
	
	public func finishWorkout(id: UUID, endDate: Date) {
		presenter?.didStartFinishing()
		
		finisher.finish(workoutID: id, at: endDate) { [weak self] result in
			switch result {
			case let .success(summary):
				self?.presenter?.didFinish(with: summary)
			case let .failure(error):
				self?.presenter?.didFinish(with: error)
			}
		}
	}
	
	public func requestDiscardConfirmation() {
		presenter?.requestDiscardConfirmation()
	}
	
	public func saveWorkoutAsRoutine(workout: Workout, name: String?) {
		saveRoutineHandler?(workout, name)
	}
	
	public func discardWorkout(id: UUID) {
		presenter?.didStartDiscarding()
		
		finisher.discard(workoutID: id) { [weak self] result in
			switch result {
			case .success:
				self?.presenter?.didFinishDiscarding()
			case let .failure(error):
				self?.presenter?.didFailDiscarding(with: error)
			}
		}
	}
}
