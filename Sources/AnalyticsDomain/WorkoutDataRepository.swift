import Foundation

public protocol WorkoutDataRepository {
    func loadWorkouts(from startDate: Date?, to endDate: Date?) throws -> [WorkoutData]
}
