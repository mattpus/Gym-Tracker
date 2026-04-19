import Foundation

public final class WorkoutDurationTracker: WorkoutDurationTracking {
	private let scheduler: WorkoutDurationScheduling
	private let currentDate: () -> Date
private var activeTimers: [UUID: (start: Date, timer: any CancellableTimer, tick: (TimeInterval) -> Void)] = [:]

	public init(scheduler: WorkoutDurationScheduling, currentDate: @escaping () -> Date = Date.init) {
		self.scheduler = scheduler
		self.currentDate = currentDate
	}

	public func start(workoutID: UUID, tick: @escaping (TimeInterval) -> Void) {
		_ = stop(workoutID: workoutID)
		let startDate = currentDate()
		let timer = scheduler.scheduleRepeating(interval: 1) { [weak self] in
			guard let self else { return }
			let elapsed = self.currentDate().timeIntervalSince(startDate)
			tick(elapsed)
		}
		activeTimers[workoutID] = (startDate, timer, tick)
	}

	public func stop(workoutID: UUID) -> TimeInterval? {
		guard let entry = activeTimers.removeValue(forKey: workoutID) else {
			return nil
		}
		entry.timer.cancel()
		return currentDate().timeIntervalSince(entry.start)
	}
}
