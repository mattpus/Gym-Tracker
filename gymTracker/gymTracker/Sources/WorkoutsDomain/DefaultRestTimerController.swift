import Foundation

public actor DefaultRestTimerController: RestTimerController {
	private struct ActiveTimer {
		var configuration: RestTimerConfiguration
		var remaining: TimeInterval
		var isRunning: Bool
		var scheduler: RestTimerScheduler?
	}
	
	private var timers = [UUID: ActiveTimer]()
	private var observers = [TickHandler]()
	private let schedulerFactory: () -> RestTimerScheduler
	
	public init(schedulerFactory: @escaping () -> RestTimerScheduler = { DispatchRestTimerScheduler() }) {
		self.schedulerFactory = schedulerFactory
	}
	
	public func enable(for configuration: RestTimerConfiguration) {
		var active = timers[configuration.exerciseID] ?? ActiveTimer(configuration: configuration, remaining: configuration.duration, isRunning: false, scheduler: nil)
		active.configuration = configuration
		active.remaining = configuration.duration
		timers[configuration.exerciseID] = active
	}
	
	public func disable(exerciseID: UUID) {
		guard let timer = timers[exerciseID] else { return }
		timer.scheduler?.cancel()
		timers[exerciseID] = nil
		notify(.init(exerciseID: exerciseID, remaining: 0, isRunning: false))
	}
	
	public func toggle(for exerciseID: UUID) {
		guard var timer = timers[exerciseID] else { return }
		if timer.isRunning {
			timer.isRunning = false
			timer.scheduler?.cancel()
			timer.scheduler = nil
		} else {
			startTimer(for: exerciseID, activeTimer: &timer)
		}
		timers[exerciseID] = timer
	}
	
	public func startIfEnabled(afterSetFor exerciseID: UUID) {
		guard var timer = timers[exerciseID] else { return }
		timer.remaining = timer.configuration.duration
		startTimer(for: exerciseID, activeTimer: &timer)
		timers[exerciseID] = timer
	}
	
	public func cancel(exerciseID: UUID) {
		guard var timer = timers[exerciseID] else { return }
		timer.scheduler?.cancel()
		timer.scheduler = nil
		timer.isRunning = false
		timers[exerciseID] = timer
		notify(.init(exerciseID: exerciseID, remaining: timer.remaining, isRunning: false))
	}
	
	public func observe(_ handler: @escaping TickHandler) {
		observers.append(handler)
	}
	
	private func startTimer(for exerciseID: UUID, activeTimer: inout ActiveTimer) {
		activeTimer.scheduler?.cancel()
		activeTimer.isRunning = true
		let scheduler = schedulerFactory()
		scheduler.start { [weak self] in
			await self?.handleTick(for: exerciseID)
		}
		activeTimer.scheduler = scheduler
	}
	
	private func handleTick(for exerciseID: UUID) {
		guard var timer = timers[exerciseID] else { return }
		timer.remaining = max(timer.remaining - 1, 0)
		if timer.remaining == 0 {
			timer.isRunning = false
			timer.scheduler?.cancel()
			timer.scheduler = nil
		}
		timers[exerciseID] = timer
		notify(.init(exerciseID: exerciseID, remaining: timer.remaining, isRunning: timer.isRunning))
	}
	
	private func notify(_ state: RestTimerState) {
		for observer in observers {
			Task {
				await observer(state)
			}
		}
	}
}

public protocol RestTimerScheduler {
	func start(_ tick: @escaping @Sendable () async -> Void)
	func cancel()
}

public final class DispatchRestTimerScheduler: RestTimerScheduler {
	private var task: Task<Void, Never>?
	private let intervalNanoseconds: UInt64
	
	public init(intervalNanoseconds: UInt64 = 1_000_000_000) {
		self.intervalNanoseconds = intervalNanoseconds
	}
	
	public func start(_ tick: @escaping @Sendable () async -> Void) {
		task?.cancel()
		let interval = intervalNanoseconds
		task = Task {
			while !Task.isCancelled {
				try? await Task.sleep(nanoseconds: interval)
				await tick()
			}
		}
	}
	
	public func cancel() {
		task?.cancel()
		task = nil
	}
}
