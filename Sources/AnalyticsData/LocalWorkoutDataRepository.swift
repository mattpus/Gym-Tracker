import Foundation
import AnalyticsDomain
import WorkoutsDomain

public final class LocalWorkoutDataRepository: WorkoutDataRepository {
    private let workoutRepository: WorkoutRepository
    private let exerciseLibraryLookup: ExerciseMuscleGroupLookup?
    
    public init(workoutRepository: WorkoutRepository, exerciseLibraryLookup: ExerciseMuscleGroupLookup? = nil) {
        self.workoutRepository = workoutRepository
        self.exerciseLibraryLookup = exerciseLibraryLookup
    }
    
    public func loadWorkouts(from startDate: Date?, to endDate: Date?) throws -> [WorkoutData] {
        var workouts = try workoutRepository.loadWorkouts()
        
        if let start = startDate {
            workouts = workouts.filter { $0.date >= start }
        }
        if let end = endDate {
            workouts = workouts.filter { $0.date <= end }
        }
        
        return workouts.map { workout in
            let exercises = workout.exercises.map { exercise -> ExerciseData in
                let muscleGroup = exerciseLibraryLookup?.muscleGroup(for: exercise.name)
                let sets = exercise.sets.map { SetData(weight: $0.weight, reps: $0.repetitions) }
                return ExerciseData(name: exercise.name, muscleGroup: muscleGroup, sets: sets)
            }
            
            let totalVolume = workout.exercises.reduce(0.0) { total, exercise in
                total + exercise.sets.reduce(0.0) { setTotal, set in
                    if let weight = set.weight, let reps = set.repetitions {
                        return setTotal + (weight * Double(reps))
                    }
                    return setTotal
                }
            }
            
            return WorkoutData(
                id: workout.id,
                date: workout.date,
                name: workout.name,
                totalVolume: totalVolume,
                exercises: exercises
            )
        }
    }
}

public protocol ExerciseMuscleGroupLookup {
    func muscleGroup(for exerciseName: String) -> String?
}
