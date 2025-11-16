import Foundation

public final class DefaultRestTimerController: RestTimerController {
	private struct ActiveTimer {
		var configuration: RestTimerConfiguration
		var remaining: TimeInterval
		var isRunning: Bool
		var scheduler: RestTimerScheduler?
	}
	
	private var timers = [UUID: ActiveTimer]()
	private let queue: DispatchQueue
	private let schedulerFactory: (DispatchQueue) -> RestTimerScheduler
	private var tickHandlers = [TickHandler]()
	
	public convenience init(queue: DispatchQueue = DispatchQueue(label: "RestTimerController")) {
		self.init(queue: queue, schedulerFactory: DefaultRestTimerController.makeDefaultScheduler)
	}
	
	public init(
		queue: DispatchQueue,
		schedulerFactory: @escaping (DispatchQueue) -> RestTimerScheduler
	) {
		self.queue = queue
		self.schedulerFactory = schedulerFactory
	}
	
	public func enable(for configuration: RestTimerConfiguration) {
		queue.sync(execute: {
			var active = timers[configuration.exerciseID] ?? ActiveTimer(configuration: configuration, remaining: configuration.duration, isRunning: false, scheduler: nil)
			active.configuration = configuration
			active.remaining = configuration.duration
			timers[configuration.exerciseID] = active
		})
	}
	
	public func disable(exerciseID: UUID) {
		queue.sync(execute: {
			guard var timer = timers[exerciseID] else { return }
			timer.scheduler?.cancel()
			timers[exerciseID] = nil
			
			let state = RestTimerState(exerciseID: exerciseID, remaining: 0, isRunning: false)
			notify(state)
		})
	}
	
	public func toggle(for exerciseID: UUID) {
		queue.sync(execute: {
			guard var timer = timers[exerciseID] else { return }
			if timer.isRunning {
				timer.isRunning = false
				timer.scheduler?.cancel()
				timer.scheduler = nil
			} else {
				startTimer(for: exerciseID, activeTimer: &timer)
			}
			timers[exerciseID] = timer
		})
	}
	
	public func startIfEnabled(afterSetFor exerciseID: UUID) {
		queue.sync(execute: {
			guard var timer = timers[exerciseID] else { return }
			timer.remaining = timer.configuration.duration
			startTimer(for: exerciseID, activeTimer: &timer)
			timers[exerciseID] = timer
		})
	}
	
	public func cancel(exerciseID: UUID) {
		queue.sync(execute: {
			guard var timer = timers[exerciseID] else { return }
			timer.scheduler?.cancel()
			timer.scheduler = nil
			timer.isRunning = false
			timers[exerciseID] = timer
			
			let state = RestTimerState(exerciseID: exerciseID, remaining: timer.remaining, isRunning: false)
			notify(state)
		})
	}
	
	public func observe(_ handler: @escaping TickHandler) {
		queue.sync(execute: {
			tickHandlers.append(handler)
		})
	}
	
	private func startTimer(for exerciseID: UUID, activeTimer: inout ActiveTimer) {
		activeTimer.scheduler?.cancel()
		activeTimer.isRunning = true
		let scheduler = schedulerFactory(queue)
		scheduler.start { [weak self] in
			self?.handleTick(for: exerciseID)
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
		let state = RestTimerState(exerciseID: exerciseID, remaining: timer.remaining, isRunning: timer.isRunning)
		notify(state)
	}
	
	private func notify(_ state: RestTimerState) {
		for handler in tickHandlers {
			handler(state)
		}
	}
	
	private static func makeDefaultScheduler(queue: DispatchQueue) -> RestTimerScheduler {
		DispatchRestTimerScheduler(queue: queue)
	}
}

public protocol RestTimerScheduler {
	func start(_ tick: @escaping () -> Void)
	func cancel()
}

private final class DispatchRestTimerScheduler: RestTimerScheduler {
	private let queue: DispatchQueue
	private var timer: DispatchSourceTimer?
	
	init(queue: DispatchQueue) {
		self.queue = queue
	}
	
	func start(_ tick: @escaping () -> Void) {
		timer?.cancel()
		let source = DispatchSource.makeTimerSource(queue: queue)
		source.schedule(deadline: .now(), repeating: 1)
		source.setEventHandler(handler: tick)
		timer = source
		source.resume()
	}
	
	func cancel() {
		timer?.cancel()
		timer = nil
	}
}
