import SwiftUI

/// Routine selection view for starting a workout from a template
struct RoutineSelectionView: View {
    @Bindable var viewModel: RoutineSelectionViewModel
    let router: WorkoutsRouter
    
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
                        router.dismissRoutineSelection()
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
                    router.startEmptyWorkout()
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
            
            Section("Your Routines") {
                ForEach(viewModel.routines) { routine in
                    Button {
                        if let fullRoutine = viewModel.routine(for: routine.id) {
                            router.startWorkoutFromRoutine(fullRoutine)
                        }
                    } label: {
                        RoutineRowView(routine: routine)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("routineRow_\(routine.id)")
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
                router.dismissRoutineSelection()
                router.showRoutineBuilder()
            } label: {
                Text("Create Routine")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                router.startEmptyWorkout()
            } label: {
                Text("Start Empty Workout")
            }
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
