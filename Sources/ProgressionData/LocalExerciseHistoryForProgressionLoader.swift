import Foundation
import ProgressionDomain
import WorkoutsDomain

public final class LocalExerciseHistoryForProgressionLoader: ExerciseHistoryForProgressionLoading {
    private let historyRepository: ExerciseHistoryRepository
    
    public init(historyRepository: ExerciseHistoryRepository) {
        self.historyRepository = historyRepository
    }
    
    public func loadHistory(for exerciseName: String, limit: Int) throws -> ExerciseHistoryForProgression {
        let records = try historyRepository.loadHistory(for: exerciseName)
        
        // Convert to HistoricalSets (most recent first)
        let sortedRecords = records.sorted { $0.date > $1.date }
        let limitedRecords = Array(sortedRecords.prefix(limit))
        
        let historicalSets = limitedRecords.map { record in
            HistoricalSet(
                date: record.date,
                weight: record.weight,
                reps: record.repetitions,
                wasCompleted: true
            )
        }
        
        // Calculate personal record
        let personalRecord = calculatePersonalRecord(from: records)
        
        return ExerciseHistoryForProgression(
            exerciseName: exerciseName,
            recentSets: historicalSets,
            personalRecord: personalRecord
        )
    }
    
    private func calculatePersonalRecord(from records: [ExercisePerformanceRecord]) -> PersonalRecord? {
        let recordsWithWeight = records.filter { $0.weight != nil }
        
        guard let maxWeightRecord = recordsWithWeight.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }),
              let maxWeight = maxWeightRecord.weight else {
            return nil
        }
        
        let maxVolumeRecord = records.compactMap { record -> (record: ExercisePerformanceRecord, volume: Double)? in
            guard let volume = record.volume else { return nil }
            return (record, volume)
        }.max { $0.volume < $1.volume }
        
        return PersonalRecord(
            maxWeight: maxWeight,
            maxWeightReps: maxWeightRecord.repetitions,
            maxWeightDate: maxWeightRecord.date,
            maxVolume: maxVolumeRecord?.volume,
            maxVolumeDate: maxVolumeRecord?.record.date
        )
    }
}
