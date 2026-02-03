import Foundation
import WorkoutsDomain

public final class LocalExerciseHistoryRepository: ExerciseHistoryRepository {
    private let store: WorkoutStore
    
    public init(store: WorkoutStore) {
        self.store = store
    }
    
    public func loadHistory(for exerciseName: String) throws -> [ExercisePerformanceRecord] {
        let query = WorkoutHistoryQuery.forExercise(exerciseName)
        return try loadHistory(query: query)
    }
    
    public func loadHistory(query: WorkoutHistoryQuery) throws -> [ExercisePerformanceRecord] {
        guard let cache = try store.retrieve() else {
            return []
        }
        
        var workouts = cache.workouts.toModels()
        
        // Apply date filters
        if let startDate = query.startDate {
            workouts = workouts.filter { $0.date >= startDate }
        }
        if let endDate = query.endDate {
            workouts = workouts.filter { $0.date <= endDate }
        }
        
        // Sort by date descending (most recent first)
        workouts = workouts.sorted { $0.date > $1.date }
        
        // Convert to performance records
        var records: [ExercisePerformanceRecord] = []
        
        for workout in workouts {
            for exercise in workout.exercises {
                // Apply exercise name filter
                if let nameFilter = query.exerciseName {
                    guard exercise.name.lowercased() == nameFilter.lowercased() else {
                        continue
                    }
                }
                
                for set in exercise.sets {
                    let record = ExercisePerformanceRecord(
                        date: workout.date,
                        workoutId: workout.id,
                        exerciseName: exercise.name,
                        setNumber: set.order,
                        weight: set.weight,
                        repetitions: set.repetitions,
                        duration: set.duration
                    )
                    records.append(record)
                }
            }
        }
        
        // Apply limit if specified
        if let limit = query.limit, records.count > limit {
            records = Array(records.prefix(limit))
        }
        
        return records
    }
    
    public func loadAllExerciseNames() throws -> [String] {
        guard let cache = try store.retrieve() else {
            return []
        }
        
        var names = Set<String>()
        for workout in cache.workouts {
            for exercise in workout.exercises {
                names.insert(exercise.name)
            }
        }
        
        return names.sorted()
    }
}
