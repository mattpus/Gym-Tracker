import SwiftUI
import WorkoutsDomain

/// Routine selection view for starting a workout from a template
struct RoutineSelectionView: View {
    @Bindable var viewModel: RoutineSelectionViewModel
    let coordinator: WorkoutsCoordinator
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.routines.isEmpty {
                    ProgressView("Loading routines...")
                } else if viewModel.routines.isEmpty {
                    emptyStateView
                } else {
                    routinesList
                }
            }
            .navigationTitle("Select Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        coordinator.dismissRoutineSelection()
                    }
                }
            }
            .onAppear {
                viewModel.loadRoutines()
            }
        }
    }
    
    private var routinesList: some View {
        List {
            // Quick start option
            Section {
                Button {
                    coordinator.dismissRoutineSelection()
                    coordinator.startEmptyWorkout()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Empty Workout")
                                .font(.headline)
                            Text("Start from scratch")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // Routines
            Section("Your Routines") {
                ForEach(viewModel.routines) { routine in
                    RoutineRowView(routine: routine)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Create a Routine from the ViewModel data
                            // In a real implementation, we'd fetch the full routine
                            let routineToStart = Routine(
                                id: routine.id,
                                name: routine.name,
                                exercises: []
                            )
                            coordinator.startWorkoutFromRoutine(routineToStart)
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Routines", systemImage: "doc.text")
        } description: {
            Text("Create routines to quickly start workouts with your favorite exercises.")
        } actions: {
            Button {
                coordinator.dismissRoutineSelection()
                coordinator.startEmptyWorkout()
            } label: {
                Text("Start Empty Workout")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/// Row view for a single routine
struct RoutineRowView: View {
    let routine: RoutineItemViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(routine.name)
                .font(.headline)
            
            HStack {
                Label("\(routine.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !routine.exerciseSummary.isEmpty {
                Text(routine.exerciseSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
