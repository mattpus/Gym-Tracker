import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RestTimerPresentationAdapterTests: XCTestCase {
	
	func test_enable_usesConfigurationProvider() {
		let controller = RestTimerControllerSpy()
		let config = RestTimerConfiguration(duration: 30, exerciseID: UUID())
		let sut = RestTimerPresentationAdapter(controller: controller) { _ in config }
		
		sut.enable(for: config.exerciseID)
		
		XCTAssertEqual(controller.messages, [.enable(config)])
	}
	
	func test_toggle_delegatesToController() {
		let controller = RestTimerControllerSpy()
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		let id = UUID()
		
		sut.toggle(for: id)
		
		XCTAssertEqual(controller.messages, [.toggle(id)])
	}
	
	func test_handleSetCompletion_startsTimerIfEnabled() {
		let controller = RestTimerControllerSpy()
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		let id = UUID()
		
		sut.handleSetCompletion(for: id)
		
		XCTAssertEqual(controller.messages, [.startAfter(id)])
	}
	
	func test_controllerTicks_areForwardedToPresenter() {
		let controller = RestTimerControllerSpy()
		let view = RestTimerViewSpy()
		let presenter = RestTimerPresenter(restTimerView: view, alertView: view)
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		sut.presenter = presenter
		let state = RestTimerState(exerciseID: UUID(), remaining: 10, isRunning: true)
		
		controller.handler?(state)
		
		XCTAssertEqual(view.timerViewModels, [
			RestTimerViewModel(exerciseID: state.exerciseID, remaining: 10, isRunning: true)
		])
	}
	
	// MARK: - Helpers
	
	private final class RestTimerControllerSpy: RestTimerController {
		enum Message: Equatable {
			case enable(RestTimerConfiguration)
			case disable(UUID)
			case toggle(UUID)
			case startAfter(UUID)
			case cancel(UUID)
		}
		
		private(set) var messages = [Message]()
		var handler: TickHandler?
		
		func enable(for configuration: RestTimerConfiguration) {
			messages.append(.enable(configuration))
		}
		
		func disable(exerciseID: UUID) {
			messages.append(.disable(exerciseID))
		}
		
		func toggle(for exerciseID: UUID) {
			messages.append(.toggle(exerciseID))
		}
		
		func startIfEnabled(afterSetFor exerciseID: UUID) {
			messages.append(.startAfter(exerciseID))
		}
		
		func cancel(exerciseID: UUID) {
			messages.append(.cancel(exerciseID))
		}
		
		func observe(_ handler: @escaping TickHandler) {
			self.handler = handler
		}
	}
	
	private final class RestTimerViewSpy: RestTimerView, RestTimerAlertView {
		private(set) var timerViewModels = [RestTimerViewModel]()
		private(set) var alertViewModels = [RestTimerAlertViewModel]()
		
		func display(_ viewModel: RestTimerViewModel) {
			timerViewModels.append(viewModel)
		}
		
		func display(_ viewModel: RestTimerAlertViewModel) {
			alertViewModels.append(viewModel)
		}
	}
}
