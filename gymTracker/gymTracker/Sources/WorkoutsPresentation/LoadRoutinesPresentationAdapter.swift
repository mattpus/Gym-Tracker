import Foundation

public final class LoadRoutinesPresentationAdapter {
	private let routinesLoader: RoutinesLoading
	public var presenter: RoutinesPresenter?
	
	public init(routinesLoader: RoutinesLoading) {
		self.routinesLoader = routinesLoader
	}
	
	public func loadRoutines() {
		presenter?.didStartLoadingRoutines()
		
		routinesLoader.load { [weak self] result in
			switch result {
			case let .success(routines):
				self?.presenter?.didFinishLoadingRoutines(with: routines)
				
			case let .failure(error):
				self?.presenter?.didFinishLoadingRoutines(with: error)
			}
		}
	}
}
