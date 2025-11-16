import Foundation
import WorkoutsDomain

public protocol RestTimerHandling: AnyObject {
	func handleSetCompletion(for exerciseID: UUID)
}

public final class RestTimerPresentationAdapter: RestTimerHandling {
	private let controller: RestTimerController
	private let configurationProvider: (UUID) -> RestTimerConfiguration?
	public var presenter: RestTimerPresenter?
	
	public init(controller: RestTimerController, configurationProvider: @escaping (UUID) -> RestTimerConfiguration?) {
		self.controller = controller
		self.configurationProvider = configurationProvider
		self.controller.observe { [weak self] state in
			self?.presenter?.didUpdate(state: state)
		}
	}
	
	public func toggle(for exerciseID: UUID) {
		controller.toggle(for: exerciseID)
	}
	
	public func enable(for exerciseID: UUID) {
		guard let configuration = configurationProvider(exerciseID) else { return }
		controller.enable(for: configuration)
	}
	
	public func disable(for exerciseID: UUID) {
		controller.disable(exerciseID: exerciseID)
	}
	
	public func handleSetCompletion(for exerciseID: UUID) {
		controller.startIfEnabled(afterSetFor: exerciseID)
	}
}
