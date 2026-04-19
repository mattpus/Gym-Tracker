import Foundation

public final class ReorderExercisesPresentationAdapter {
	private let reordering: WorkoutExerciseReordering
	public var presenter: WorkoutCommandPresenter?
	public var onReordered: ((Workout) -> Void)?

	public init(reordering: WorkoutExerciseReordering) {
		self.reordering = reordering
	}

	public func reorder(workoutID: UUID, from sourceIndex: Int, to destinationIndex: Int) {
		presenter?.didStartCommand()

		reordering.reorderExercises(in: workoutID, from: sourceIndex, to: destinationIndex) { [weak self] result in
			switch result {
			case let .success(updated):
				self?.onReordered?(updated)
				self?.presenter?.didFinishCommand()

			case let .failure(error):
				self?.presenter?.didFinishCommand(with: error)
			}
		}
	}
}
