import Foundation

@MainActor
public protocol RestTimerHandling: AnyObject {
	func handleSetCompletion(for exerciseID: UUID) async
}

@MainActor
public final class RestTimerPresentationAdapter: RestTimerHandling {
	private let controller: RestTimerController
	private let configurationProvider: (UUID) -> RestTimerConfiguration?
	public var presenter: RestTimerPresenter?
	
	public init(controller: RestTimerController, configurationProvider: @escaping (UUID) -> RestTimerConfiguration?) {
		self.controller = controller
		self.configurationProvider = configurationProvider
		Task { [weak self] in
			await controller.observe { [weak self] state in
				await MainActor.run {
					self?.presenter?.didUpdate(state: state)
				}
			}
		}
	}
	
	public func toggle(for exerciseID: UUID) async {
		await controller.toggle(for: exerciseID)
	}
	
	public func enable(for exerciseID: UUID) async {
		guard let configuration = configurationProvider(exerciseID) else { return }
		await controller.enable(for: configuration)
	}
	
	public func disable(for exerciseID: UUID) async {
		await controller.disable(exerciseID: exerciseID)
	}
	
	public func handleSetCompletion(for exerciseID: UUID) async {
		await controller.startIfEnabled(afterSetFor: exerciseID)
	}
	
	public func cancelTimer(for exerciseID: UUID) async {
		await controller.cancel(exerciseID: exerciseID)
	}
}
