import SwiftUI

/// Active workout view for logging exercises during a workout session
struct ActiveWorkoutView: View {
    @Bindable var viewModel: ActiveWorkoutViewModel
    @Bindable var coordinator: WorkoutsCoordinator
    
    @State private var showingFinishConfirmation = false
    @State private var showingCancelConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Timer Header
                timerHeader
                
                // Rest Timer (if active)
                if viewModel.isRestTimerActive {
                    restTimerBanner
                }
                
                // Exercises List
                exercisesList
            }
            .navigationTitle(viewModel.workoutName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingCancelConfirmation = true
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") {
                        showingFinishConfirmation = true
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog("Finish Workout?", isPresented: $showingFinishConfirmation) {
                Button("Finish Workout") {
                    coordinator.finishActiveWorkout(viewModel.workoutId)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Save this workout to your history?")
            }
            .confirmationDialog("Cancel Workout?", isPresented: $showingCancelConfirmation) {
                Button("Discard Workout", role: .destructive) {
                    coordinator.cancelActiveWorkout(viewModel.workoutId)
                }
                Button("Continue Workout", role: .cancel) {}
            } message: {
                Text("Your workout progress will be lost.")
            }
        }
    }
    
    private var timerHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.formattedDuration)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.exercises.count)")
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var restTimerBanner: some View {
        HStack {
            Image(systemName: "timer")
            Text("Rest: \(viewModel.formattedRestTime)")
                .font(.headline)
            Spacer()
            Button("Skip") {
                viewModel.stopRestTimer()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(.blue.opacity(0.1))
    }
    
    private var exercisesList: some View {
        List {
            ForEach(viewModel.exercises) { exercise in
                ActiveExerciseSection(
                    exercise: exercise,
                    onLogSet: { setIndex, weight, reps, type in
                        viewModel.logSet(exerciseIndex: exercise.index, setIndex: setIndex, weight: weight, reps: reps, type: type)
                    },
                    onAddSet: {
                        viewModel.addSet(exerciseIndex: exercise.index)
                    },
                    onRemoveSet: { setIndex in
                        viewModel.removeSet(exerciseIndex: exercise.index, setIndex: setIndex)
                    }
                )
            }
            .onDelete { offsets in
                for index in offsets {
                    viewModel.removeExercise(at: index)
                }
            }
            .onMove { source, destination in
                viewModel.reorderExercises(from: source, to: destination)
            }
            
            // Add Exercise Button
            Button {
                coordinator.showExerciseSelection()
            } label: {
                Label("Add Exercise", systemImage: "plus.circle.fill")
            }
            .accessibilityIdentifier("addExerciseButton")
        }
        .listStyle(.insetGrouped)
    }
}

/// Section for a single exercise during active workout
struct ActiveExerciseSection: View {
    let exercise: ActiveExerciseViewModel
    let onLogSet: (Int, Double?, Int?, ExerciseSetType) -> Void
    let onAddSet: () -> Void
    let onRemoveSet: (Int) -> Void
    
    var body: some View {
        Section {
            ForEach(exercise.sets) { set in
                SetInputRow(
                    set: set,
                    onComplete: { weight, reps, type in
                        onLogSet(set.index, weight, reps, type)
                    }
                )
            }
            .onDelete { offsets in
                for index in offsets {
                    onRemoveSet(index)
                }
            }
            
            Button {
                onAddSet()
            } label: {
                Label("Add Set", systemImage: "plus")
                    .font(.subheadline)
            }
        } header: {
            HStack {
                if exercise.isInSuperset {
                    Image(systemName: "link")
                        .foregroundStyle(.orange)
                }
                Text(exercise.name)
            }
        }
    }
}

/// Input row for logging a single set
struct SetInputRow: View {
    let set: ActiveSetViewModel
    let onComplete: (Double?, Int?, ExerciseSetType) -> Void
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var setType: ExerciseSetType = .main
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Set \(set.index + 1)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)
            
            TextField("kg", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
            
            Text("×")
                .foregroundStyle(.secondary)
            
            TextField("reps", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)

            Menu {
                ForEach(ExerciseSetType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        setType = type
                    }
                }
            } label: {
                Text(setType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Button {
                let weight = Double(weightText)
                let reps = Int(repsText)
                onComplete(weight, reps, setType)
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            if let weight = set.weight {
                weightText = weight.formatted()
            }
            if let reps = set.reps {
                repsText = "\(reps)"
            }
            setType = set.type
        }
    }
}

// Import for Exercise type
