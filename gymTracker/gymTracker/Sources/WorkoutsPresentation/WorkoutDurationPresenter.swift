import Foundation

public protocol WorkoutDurationView: AnyObject {
	func display(_ viewModel: WorkoutDurationViewModel)
}

public final class WorkoutDurationPresenter {
	private let view: WorkoutDurationView

	public init(view: WorkoutDurationView) {
		self.view = view
	}

	public func didUpdateDuration(_ interval: TimeInterval) {
		view.display(.init(formattedTime: format(interval)))
	}

	private func format(_ interval: TimeInterval) -> String {
		let totalSeconds = max(0, Int(interval))
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let seconds = totalSeconds % 60
		if hours > 0 {
			return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
		}
		return String(format: "%02d:%02d", minutes, seconds)
	}
}
