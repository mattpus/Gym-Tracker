import Foundation
import WorkoutsDomain

public final class ExerciseSetLoggingPresenter {
	private let loggingView: ExerciseSetLoggingView
	private let loadingView: WorkoutCommandLoadingView
	private let errorView: WorkoutsErrorView
	
	public init(
		loggingView: ExerciseSetLoggingView,
		loadingView: WorkoutCommandLoadingView,
		errorView: WorkoutsErrorView
	) {
		self.loggingView = loggingView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLogging() {
		errorView.display(.init(message: nil))
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishLogging(with result: ExerciseSetLogResult, action: ExerciseSetLoggingViewModel.Action) {
		let viewModel = ExerciseSetLoggingViewModel(
			workout: result.workout,
			exercise: result.exercise,
			set: result.set,
			previousSet: result.previousSet,
			action: action,
			previousDisplay: formattedPreviousSet(result.previousSet)
		)
		loggingView.display(viewModel)
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishDeleting(with result: ExerciseSetDeletionResult) {
		let viewModel = ExerciseSetLoggingViewModel(
			workout: result.workout,
			exercise: result.exercise,
			set: nil,
			previousSet: nil,
			action: .deleted,
			previousDisplay: formattedPreviousSet(nil)
		)
		loggingView.display(viewModel)
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinish(with error: Swift.Error) {
		errorView.display(.init(message: localized(error)))
		loadingView.display(.init(isLoading: false))
	}
	
	private func localized(_ error: Swift.Error) -> String {
		"Something went wrong. Please try again."
	}

	private func formattedPreviousSet(_ set: ExerciseSet?) -> String {
		guard let set else { return "-" }
		var components = [String]()
		if let weight = set.weight {
			let text: String
			if weight.rounded() == weight {
				text = "\(Int(weight))kg"
			} else {
				text = "\(weight)kg"
			}
			components.append(text)
		}
		if let reps = set.repetitions {
			let repsText = components.isEmpty ? "\(reps) reps" : "\(reps)"
			if components.isEmpty {
				components.append(repsText)
			} else {
				components.append(repsText)
			}
		}
		if components.isEmpty {
			return "-"
		}
		if components.count == 2, components[0].contains("kg"), !components[1].contains("reps") {
			return "\(components[0]) × \(components[1])"
		}
		return components.joined(separator: " ")
	}
}
