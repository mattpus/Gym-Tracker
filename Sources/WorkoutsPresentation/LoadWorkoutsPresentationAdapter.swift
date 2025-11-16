import Foundation
import WorkoutsDomain

public final class LoadWorkoutsPresentationAdapter {
	private let workoutsLoader: WorkoutsLoading
	
	public var presenter: WorkoutsPresenter?
	
	public init(workoutsLoader: WorkoutsLoading) {
		self.workoutsLoader = workoutsLoader
	}
	
	public func loadWorkouts() {
		presenter?.didStartLoadingWorkouts()
		
		workoutsLoader.load { [weak self] result in
			switch result {
			case let .success(workouts):
				self?.presenter?.didFinishLoadingWorkouts(with: workouts)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingWorkouts(with: error)
			}
		}
	}
}
