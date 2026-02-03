import Foundation

public struct ExerciseStatistics: Equatable, Sendable {
    public let exerciseName: String
    public let totalSessions: Int
    public let totalSets: Int
    public let totalReps: Int
    public let totalVolume: Double
    public let maxWeight: Double?
    public let maxReps: Int?
    public let averageWeight: Double?
    public let averageReps: Double?
    public let firstPerformed: Date?
    public let lastPerformed: Date?
    
    public init(
        exerciseName: String,
        totalSessions: Int,
        totalSets: Int,
        totalReps: Int,
        totalVolume: Double,
        maxWeight: Double?,
        maxReps: Int?,
        averageWeight: Double?,
        averageReps: Double?,
        firstPerformed: Date?,
        lastPerformed: Date?
    ) {
        self.exerciseName = exerciseName
        self.totalSessions = totalSessions
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalVolume = totalVolume
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.averageWeight = averageWeight
        self.averageReps = averageReps
        self.firstPerformed = firstPerformed
        self.lastPerformed = lastPerformed
    }
}

extension ExerciseStatistics {
    public static func calculate(from records: [ExercisePerformanceRecord]) -> ExerciseStatistics? {
        guard !records.isEmpty else { return nil }
        
        let exerciseName = records[0].exerciseName
        let uniqueDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        
        var totalSets = 0
        var totalReps = 0
        var totalVolume: Double = 0
        var maxWeight: Double?
        var maxReps: Int?
        var weights: [Double] = []
        var reps: [Int] = []
        
        for record in records {
            totalSets += 1
            
            if let r = record.repetitions {
                totalReps += r
                reps.append(r)
                if maxReps == nil || r > maxReps! {
                    maxReps = r
                }
            }
            
            if let w = record.weight {
                weights.append(w)
                if maxWeight == nil || w > maxWeight! {
                    maxWeight = w
                }
                if let r = record.repetitions {
                    totalVolume += w * Double(r)
                }
            }
        }
        
        let sortedDates = records.map(\.date).sorted()
        let averageWeight = weights.isEmpty ? nil : weights.reduce(0, +) / Double(weights.count)
        let averageReps = reps.isEmpty ? nil : Double(reps.reduce(0, +)) / Double(reps.count)
        
        return ExerciseStatistics(
            exerciseName: exerciseName,
            totalSessions: uniqueDates.count,
            totalSets: totalSets,
            totalReps: totalReps,
            totalVolume: totalVolume,
            maxWeight: maxWeight,
            maxReps: maxReps,
            averageWeight: averageWeight,
            averageReps: averageReps,
            firstPerformed: sortedDates.first,
            lastPerformed: sortedDates.last
        )
    }
}
