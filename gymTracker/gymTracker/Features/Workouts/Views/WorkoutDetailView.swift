import SwiftUI

/// Workout detail view showing exercises and statistics
struct WorkoutDetailView: View {
    @Bindable var viewModel: WorkoutDetailViewModel
    let router: WorkoutsRouter
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let workout = viewModel.workout {
                workoutDetailContent(workout)
            } else if viewModel.error != nil {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(viewModel.error?.localizedDescription ?? "Unknown error")
                }
            }
        }
        .navigationTitle(viewModel.workout?.name ?? "Workout")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if let workout = viewModel.workout {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        router.editFinishedWorkout(workoutId: workout.id)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadWorkoutDetail()
        }
    }
    
    private func workoutDetailContent(_ workout: WorkoutDetailItem) -> some View {
        List {
            // Statistics Section
            if let stats = viewModel.statistics {
                Section("Statistics") {
                    StatisticsRow(title: "Total Volume", value: stats.formattedVolume)
                    StatisticsRow(title: "Total Sets", value: "\(stats.totalSets)")
                    StatisticsRow(title: "Total Reps", value: "\(stats.totalReps)")
                }
            }
            
            // Exercises Section
            Section("Exercises") {
                ForEach(workout.exercises) { exercise in
                    ExerciseDetailRow(exercise: exercise)
                }
            }
            
            // Notes Section
            if let notes = workout.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// Row displaying statistics
struct StatisticsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

/// Row displaying exercise detail with sets
struct ExerciseDetailRow: View {
    let exercise: ExerciseDetailItem
    @State private var isExpanded = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(exercise.sets) { set in
                HStack {
                    Text("Set \(set.index)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(set.displayText)
                        .font(.subheadline)
                }
            }
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        } label: {
            HStack {
                if exercise.supersetId != nil {
                    Image(systemName: "link")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                Text(exercise.name)
                    .font(.headline)
            }
        }
    }
}
