import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class RestTimerPresentationAdapterTests: XCTestCase {
	
	func test_enable_usesConfigurationProvider() async {
		let controller = RestTimerControllerSpy()
		let config = RestTimerConfiguration(duration: 30, exerciseID: UUID())
		let sut = RestTimerPresentationAdapter(controller: controller) { _ in config }
		
		await sut.enable(for: config.exerciseID)
		
		let messages = await controller.messages
		XCTAssertEqual(messages, [.enable(config)])
	}
	
	func test_toggle_delegatesToController() async {
		let controller = RestTimerControllerSpy()
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		let id = UUID()
		
		await sut.toggle(for: id)
		
		let messages = await controller.messages
		XCTAssertEqual(messages, [.toggle(id)])
	}
	
	func test_handleSetCompletion_startsTimerIfEnabled() async {
		let controller = RestTimerControllerSpy()
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		let id = UUID()
		
		await sut.handleSetCompletion(for: id)
		
		let messages = await controller.messages
		XCTAssertEqual(messages, [.startAfter(id)])
	}
	
	func test_controllerTicks_areForwardedToPresenter() async {
		let controller = RestTimerControllerSpy()
		let observeExp = expectation(description: "observe")
		let view = RestTimerViewSpy()
		let presenter = RestTimerPresenter(restTimerView: view, alertView: view)
		let sut = RestTimerPresentationAdapter(controller: controller, configurationProvider: { _ in nil })
		sut.presenter = presenter
		let state = RestTimerState(exerciseID: UUID(), remaining: 10, isRunning: true)
		
		Task {
			while await controller.handler == nil {
				try? await Task.sleep(nanoseconds: 10_000_000)
			}
			observeExp.fulfill()
		}
		
		await fulfillment(of: [observeExp], timeout: 1.0)
		let handler = await controller.handler
		await handler?(state)
		
		XCTAssertEqual(view.timerViewModels, [
			RestTimerViewModel(exerciseID: state.exerciseID, remaining: 10, isRunning: true)
		])
	}
	
	// MARK: - Helpers
	
	private actor RestTimerControllerSpy: RestTimerController {
		enum Message: Equatable {
			case enable(RestTimerConfiguration)
			case disable(UUID)
			case toggle(UUID)
			case startAfter(UUID)
			case cancel(UUID)
		}
		
		private var recordedMessages = [Message]()
		private var tickHandler: TickHandler?
		
		var messages: [Message] {
			get async { recordedMessages }
		}
		
		var handler: TickHandler? {
			get async { tickHandler }
		}
		
		func enable(for configuration: RestTimerConfiguration) async {
			recordedMessages.append(.enable(configuration))
		}
		
		func disable(exerciseID: UUID) async {
			recordedMessages.append(.disable(exerciseID))
		}
		
		func toggle(for exerciseID: UUID) async {
			recordedMessages.append(.toggle(exerciseID))
		}
		
		func startIfEnabled(afterSetFor exerciseID: UUID) async {
			recordedMessages.append(.startAfter(exerciseID))
		}
		
		func cancel(exerciseID: UUID) async {
			recordedMessages.append(.cancel(exerciseID))
		}
		
		func observe(_ handler: @escaping TickHandler) async {
			tickHandler = handler
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
