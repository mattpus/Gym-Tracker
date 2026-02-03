import Foundation

public struct WorkoutHistoryQuery: Equatable, Sendable {
    public let startDate: Date?
    public let endDate: Date?
    public let exerciseName: String?
    public let limit: Int?
    
    public init(
        startDate: Date? = nil,
        endDate: Date? = nil,
        exerciseName: String? = nil,
        limit: Int? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.exerciseName = exerciseName
        self.limit = limit
    }
    
    public static var all: WorkoutHistoryQuery {
        WorkoutHistoryQuery()
    }
    
    public static func lastDays(_ days: Int) -> WorkoutHistoryQuery {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)
        return WorkoutHistoryQuery(startDate: startDate, endDate: endDate)
    }
    
    public static func forExercise(_ name: String) -> WorkoutHistoryQuery {
        WorkoutHistoryQuery(exerciseName: name)
    }
}
