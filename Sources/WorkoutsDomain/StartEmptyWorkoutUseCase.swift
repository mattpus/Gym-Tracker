import Foundation

public final class StartEmptyWorkoutUseCase: EmptyWorkoutStarting {
	private let scheduler: WorkoutScheduling
	private let currentDate: () -> Date
	private let uuid: () -> UUID
	
	public init(
		scheduler: WorkoutScheduling,
		currentDate: @escaping () -> Date,
		uuid: @escaping () -> UUID = UUID.init
	) {
		self.scheduler = scheduler
		self.currentDate = currentDate
		self.uuid = uuid
	}
	
	public func startEmptyWorkout(named name: String?, completion: @escaping (WorkoutScheduling.Result) -> Void) {
		let workout = Workout(
			id: uuid(),
			date: currentDate(),
			name: name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? name! : "Untitled Workout",
			exercises: []
		)
		
		scheduler.schedule(workout, completion: completion)
	}
}
