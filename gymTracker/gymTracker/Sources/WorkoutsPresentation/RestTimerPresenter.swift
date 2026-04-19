import Foundation

public final class RestTimerPresenter {
	private let restTimerView: RestTimerView
	private let alertView: RestTimerAlertView
	
	public init(restTimerView: RestTimerView, alertView: RestTimerAlertView) {
		self.restTimerView = restTimerView
		self.alertView = alertView
	}
	
	public func didUpdate(state: RestTimerState) {
		restTimerView.display(.init(exerciseID: state.exerciseID, remaining: state.remaining, isRunning: state.isRunning))
		
		if state.remaining == 0 {
			alertView.display(.init(exerciseID: state.exerciseID, shouldPlayAlert: true))
		} else {
			alertView.display(.init(exerciseID: state.exerciseID, shouldPlayAlert: false))
		}
	}
}
