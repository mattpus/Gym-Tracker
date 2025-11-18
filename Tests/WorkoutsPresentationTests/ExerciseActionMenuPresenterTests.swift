import XCTest
import WorkoutsDomain
@testable import WorkoutsPresentation

@MainActor
final class ExerciseActionMenuPresenterTests: XCTestCase {

	func test_presentMenu_displaysMenuItems() {
		let view = ViewSpy()
		let sut = ExerciseActionMenuPresenter(view: view)
		let workoutID = UUID()
		let exercise = Exercise(id: UUID(), name: "Bench", notes: nil, sets: [])

		sut.presentMenu(for: workoutID, exercise: exercise)

		let expectedItems: [ExerciseActionMenuItemViewModel] = [
			.init(action: .reorder, title: "Reorder", isEnabled: true),
			.init(action: .replace, title: "Replace", isEnabled: true),
			.init(action: .removeFromSuperset, title: "Remove from Superset", isEnabled: false),
			.init(action: .removeExercise, title: "Remove Exercise", isEnabled: true)
		]
		XCTAssertEqual(view.viewModels, [.init(exerciseID: exercise.id, items: expectedItems)])
	}

	func test_presentMenu_enablesSupersetRemovalWhenExerciseLinked() {
		let view = ViewSpy()
		let sut = ExerciseActionMenuPresenter(view: view)
		let exercise = Exercise(id: UUID(), name: "Bench", notes: nil, sets: [], supersetID: UUID(), supersetOrder: 0)

		sut.presentMenu(for: UUID(), exercise: exercise)

		XCTAssertEqual(view.viewModels.first?.items[2].isEnabled, true)
	}

	func test_selectAction_invokesHandlersWithIDs() {
		let view = ViewSpy()
		let sut = ExerciseActionMenuPresenter(view: view)
		let workoutID = UUID()
		let exercise = Exercise(id: UUID(), name: "Bench", notes: nil, sets: [])
		var received = [(ExerciseActionMenuItemViewModel.Action, UUID, UUID)]()
		sut.onReorderRequested = { received.append((.reorder, $0, $1)) }
		sut.onReplaceRequested = { received.append((.replace, $0, $1)) }
		sut.onRemoveRequested = { received.append((.removeExercise, $0, $1)) }

		sut.presentMenu(for: workoutID, exercise: exercise)
		sut.select(.reorder)
		sut.select(.replace)
		sut.select(.removeExercise)

		XCTAssertEqual(received.map { $0.0 }, [.reorder, .replace, .removeExercise])
		XCTAssertTrue(received.allSatisfy { $0.1 == workoutID && $0.2 == exercise.id })
	}

	func test_selectRemoveFromSuperset_onlyInvokesForLinkedExercises() {
		let view = ViewSpy()
		let sut = ExerciseActionMenuPresenter(view: view)
		let workoutID = UUID()
		var handledPairs = [(UUID, UUID)]()
		sut.onRemoveFromSupersetRequested = { handledPairs.append(($0, $1)) }

		let unlinked = Exercise(id: UUID(), name: "A", notes: nil, sets: [])
		sut.presentMenu(for: workoutID, exercise: unlinked)
		sut.select(.removeFromSuperset)
		XCTAssertTrue(handledPairs.isEmpty)

		let linked = Exercise(id: UUID(), name: "B", notes: nil, sets: [], supersetID: UUID(), supersetOrder: 0)
		sut.presentMenu(for: workoutID, exercise: linked)
		sut.select(.removeFromSuperset)
		XCTAssertEqual(handledPairs.count, 1)
		XCTAssertEqual(handledPairs.first?.0, workoutID)
		XCTAssertEqual(handledPairs.first?.1, linked.id)
	}

	func test_selectWithoutContext_doesNothing() {
		let view = ViewSpy()
		let sut = ExerciseActionMenuPresenter(view: view)
		sut.onReorderRequested = { _, _ in XCTFail("Should not be called") }

		sut.select(.reorder)
	}

	// MARK: - Helpers

	private final class ViewSpy: ExerciseActionMenuView {
		private(set) var viewModels = [ExerciseActionMenuViewModel]()

		func display(_ viewModel: ExerciseActionMenuViewModel) {
			viewModels.append(viewModel)
		}
	}
}
