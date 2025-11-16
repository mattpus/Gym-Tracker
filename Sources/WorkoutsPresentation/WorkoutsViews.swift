import Foundation

public protocol WorkoutsView {
	func display(_ viewModel: WorkoutsViewModel)
}

public protocol WorkoutsLoadingView {
	func display(_ viewModel: WorkoutsLoadingViewModel)
}

public protocol WorkoutsErrorView {
	func display(_ viewModel: WorkoutsErrorViewModel)
}
