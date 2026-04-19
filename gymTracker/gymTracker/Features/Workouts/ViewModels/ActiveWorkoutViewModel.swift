import Foundation
import Observation
import SwiftUI

/// ViewModel for the active workout screen
@Observable
@MainActor
final class ActiveWorkoutViewModel {
    var workout: Workout
    let isEditingFinishedWorkout: Bool
    var exercises: [ActiveExerciseViewModel] = []
    var workoutDuration: TimeInterval = 0
    var isRestTimerActive = false
    var restTimeRemaining: TimeInterval = 0
    
    private let exerciseSetLoggingUseCase: ExerciseSetLogging
    private let updateNotesUseCase: ExerciseNotesUpdating
    private let editWorkoutUseCase: WorkoutEditing
    
    private var durationTimer: Timer?
    private var restTimer: Timer?
    
    init(
        workout: Workout,
        exerciseSetLoggingUseCase: ExerciseSetLogging,
        updateNotesUseCase: ExerciseNotesUpdating,
        editWorkoutUseCase: WorkoutEditing,
        isEditingFinishedWorkout: Bool = false
    ) {
        self.workout = workout
        self.isEditingFinishedWorkout = isEditingFinishedWorkout
        self.exerciseSetLoggingUseCase = exerciseSetLoggingUseCase
        self.updateNotesUseCase = updateNotesUseCase
        self.editWorkoutUseCase = editWorkoutUseCase
        
        updateExercises()
        startDurationTimer()
    }
    
    func cleanup() {
        durationTimer?.invalidate()
        restTimer?.invalidate()
    }
    
    var workoutName: String {
        workout.name
    }
    
    var workoutId: UUID {
        workout.id
    }
    
    var formattedDuration: String {
        let hours = Int(workoutDuration) / 3600
        let minutes = (Int(workoutDuration) % 3600) / 60
        let seconds = Int(workoutDuration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var formattedRestTime: String {
        let minutes = Int(restTimeRemaining) / 60
        let seconds = Int(restTimeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Timer Management
    
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.workoutDuration += 1
            }
        }
    }
    
    func startRestTimer(duration: TimeInterval = 90) {
        restTimeRemaining = duration
        isRestTimerActive = true
        
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.restTimeRemaining > 0 {
                    self.restTimeRemaining -= 1
                } else {
                    self.stopRestTimer()
                }
            }
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerActive = false
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: Exercise) {
        var updatedExercises = workout.exercises
        updatedExercises.append(exercise)
        let updatedWorkout = Workout(
            id: workout.id,
            date: workout.date,
            name: workout.name,
            notes: workout.notes,
            exercises: updatedExercises
        )
        persist(updatedWorkout)
    }
    
    func removeExercise(at index: Int) {
        var updatedExercises = workout.exercises
        updatedExercises.remove(at: index)
        let updatedWorkout = Workout(
            id: workout.id,
            date: workout.date,
            name: workout.name,
            notes: workout.notes,
            exercises: updatedExercises
        )
        persist(updatedWorkout)
    }
    
    func reorderExercises(from source: IndexSet, to destination: Int) {
        var updatedExercises = workout.exercises
        updatedExercises.move(fromOffsets: source, toOffset: destination)
        let updatedWorkout = Workout(
            id: workout.id,
            date: workout.date,
            name: workout.name,
            notes: workout.notes,
            exercises: updatedExercises
        )
        persist(updatedWorkout)
    }
    
    // MARK: - Set Logging
    
    func logSet(exerciseIndex: Int, setIndex: Int, weight: Double?, reps: Int?, type: ExerciseSetType) {
        guard exerciseIndex < workout.exercises.count,
              setIndex < workout.exercises[exerciseIndex].sets.count else { return }
        
        let exercise = workout.exercises[exerciseIndex]
        let set = exercise.sets[setIndex]
        
        let request = ExerciseSetRequest(type: type, repetitions: reps, weight: weight, duration: nil, isCompleted: true)
        
        exerciseSetLoggingUseCase.updateSet(
            in: workout.id,
            exerciseID: exercise.id,
            setID: set.id,
            request: request
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if case let .success(logResult) = result {
                    self.workout = logResult.workout
                    self.updateExercises()
                    self.startRestTimer()
                }
            }
        }
    }
    
    func addSet(exerciseIndex: Int) {
        guard exerciseIndex < workout.exercises.count else { return }
        
        let exercise = workout.exercises[exerciseIndex]
        let request = ExerciseSetRequest(type: .main, repetitions: nil, weight: nil, duration: nil, isCompleted: false)
        
        exerciseSetLoggingUseCase.addSet(
            to: workout.id,
            exerciseID: exercise.id,
            request: request
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if case let .success(logResult) = result {
                    self.workout = logResult.workout
                    self.updateExercises()
                }
            }
        }
    }
    
    func removeSet(exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < workout.exercises.count,
              setIndex < workout.exercises[exerciseIndex].sets.count else { return }
        
        let exercise = workout.exercises[exerciseIndex]
        let set = exercise.sets[setIndex]
        
        exerciseSetLoggingUseCase.deleteSet(
            in: workout.id,
            exerciseID: exercise.id,
            setID: set.id
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if case let .success(deleteResult) = result {
                    self.workout = deleteResult.workout
                    self.updateExercises()
                }
            }
        }
    }
    
    // MARK: - Notes
    
    func updateNotes(exerciseIndex: Int, notes: String) {
        guard exerciseIndex < workout.exercises.count else { return }
        
        let exercise = workout.exercises[exerciseIndex]
        
        updateNotesUseCase.updateNotes(
            in: workout.id,
            exerciseID: exercise.id,
            notes: notes.isEmpty ? nil : notes
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if case let .success(updatedWorkout) = result {
                    self.workout = updatedWorkout
                    self.updateExercises()
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func updateExercises() {
        exercises = workout.exercises.enumerated().map { index, exercise in
            ActiveExerciseViewModel(exercise: exercise, index: index)
        }
    }

    private func persist(_ updatedWorkout: Workout) {
        editWorkoutUseCase.edit(updatedWorkout) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if case .success = result {
                    self.workout = updatedWorkout
                    self.updateExercises()
                }
            }
        }
    }
}

/// ViewModel for an exercise during active workout
struct ActiveExerciseViewModel: Identifiable {
    let id: UUID
    let index: Int
    let name: String
    var sets: [ActiveSetViewModel]
    let notes: String?
    let supersetId: UUID?
    
    init(exercise: Exercise, index: Int) {
        self.id = exercise.id
        self.index = index
        self.name = exercise.name
        self.sets = exercise.sets.enumerated().map { setIndex, set in
            ActiveSetViewModel(set: set, index: setIndex)
        }
        self.notes = exercise.notes
        self.supersetId = exercise.supersetID
    }
    
    var isInSuperset: Bool {
        supersetId != nil
    }
}

/// ViewModel for a set during active workout
struct ActiveSetViewModel: Identifiable {
    let id: UUID
    let index: Int
    let type: ExerciseSetType
    var weight: Double?
    var reps: Int?
    var isCompleted: Bool
    
    init(set: ExerciseSet, index: Int) {
        self.id = set.id
        self.index = index
        self.type = set.type
        self.weight = set.weight
        self.reps = set.repetitions
        self.isCompleted = set.isCompleted
    }
}
