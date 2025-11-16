import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class LoadRoutinesPresentationAdapterTests: XCTestCase {
	
	func test_loadRoutines_startsLoading() {
		let (sut, loader, view) = makeSUT()
		
		sut.loadRoutines()
		
		XCTAssertEqual(loader.messages, [.load])
		XCTAssertEqual(view.messages, [
			.displayError(message: nil),
			.displayLoading(isLoading: true)
		])
	}
	
	func test_loadRoutines_deliversRoutinesOnSuccess() {
		let (sut, loader, view) = makeSUT()
		let routines = [makeRoutine()]
		
		sut.loadRoutines()
		loader.complete(with: routines)
		
		XCTAssertEqual(view.messages, [
			.displayError(message: nil),
			.displayLoading(isLoading: true),
			.displayRoutines(.init(routines: [
				RoutineCardViewModel(
					id: routines[0].id,
					name: routines[0].name,
					detail: "0 exercises · 0 sets",
					startButtonTitle: RoutinesPresenter.startButtonTitle
				)
			])),
			.displayLoading(isLoading: false)
		])
	}
	
	func test_loadRoutines_deliversErrorOnFailure() {
		let (sut, loader, view) = makeSUT()
		let error = NSError(domain: "test", code: 0)
		
		sut.loadRoutines()
		loader.complete(with: error)
		
		XCTAssertEqual(view.messages, [
			.displayError(message: nil),
			.displayLoading(isLoading: true),
			.displayError(message: "Could not load routines. Please try again."),
			.displayLoading(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (LoadRoutinesPresentationAdapter, RoutinesLoaderSpy, ViewSpy) {
		let loader = RoutinesLoaderSpy()
		let view = ViewSpy()
		let presenter = RoutinesPresenter(routinesView: view, loadingView: view, errorView: view)
		let sut = LoadRoutinesPresentationAdapter(routinesLoader: loader)
		sut.presenter = presenter
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(presenter, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader, view)
	}
	
	private func makeRoutine(name: String = "Push") -> Routine {
		Routine(name: name, exercises: [])
	}
	
	private final class RoutinesLoaderSpy: RoutinesLoading {
		enum Message {
			case load
		}
		
		private(set) var messages = [Message]()
		private var completions = [(RoutinesLoading.Result) -> Void]()
		
		func load(completion: @escaping (RoutinesLoading.Result) -> Void) {
			completions.append(completion)
			messages.append(.load)
		}
		
		func complete(with routines: [Routine], at index: Int = 0) {
			completions[index](.success(routines))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			completions[index](.failure(error))
		}
	}
	
	private final class ViewSpy: RoutinesView, RoutinesLoadingView, RoutinesErrorView {
		enum Message: Equatable {
			case displayRoutines(RoutinesViewModel)
			case displayLoading(isLoading: Bool)
			case displayError(message: String?)
		}
		
		private(set) var messages = [Message]()
		
		func display(_ viewModel: RoutinesViewModel) {
			messages.append(.displayRoutines(viewModel))
		}
		
		func display(_ viewModel: RoutinesLoadingViewModel) {
			messages.append(.displayLoading(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: RoutinesErrorViewModel) {
			messages.append(.displayError(message: viewModel.message))
		}
	}
}
