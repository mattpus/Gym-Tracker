import SwiftUI

/// Main workouts list view
struct WorkoutsListView: View {
    @Bindable var viewModel: WorkoutsListViewModel
    let coordinator: WorkoutsCoordinator
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.workouts.isEmpty {
                ProgressView("Loading workouts...")
            } else if viewModel.workouts.isEmpty {
                emptyStateView
            } else {
                workoutsList
            }
        }
        .navigationTitle("Workouts")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("New Routine") {
                    coordinator.showRoutineBuilder()
                }
                .accessibilityIdentifier("newRoutineButton")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        coordinator.startEmptyWorkout()
                    } label: {
                        Label("Empty Workout", systemImage: "plus")
                    }
                    
                    Button {
                        coordinator.showRoutineSelection()
                    } label: {
                        Label("From Routine", systemImage: "doc.text")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .accessibilityIdentifier("workoutAddMenuButton")
            }
        }
        .refreshable {
            viewModel.loadWorkouts()
        }
        .onAppear {
            if viewModel.workouts.isEmpty {
                viewModel.loadWorkouts()
            }
        }
    }
    
    private var workoutsList: some View {
        List {
            ForEach(viewModel.workouts) { workout in
                WorkoutRowView(workout: workout)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        coordinator.showWorkoutDetail(workoutId: workout.id)
                    }
            }
            .onDelete { offsets in
                viewModel.deleteWorkout(at: offsets)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Workouts", systemImage: "dumbbell")
        } description: {
            Text("Start your first workout to begin tracking your progress.")
        } actions: {
            Button {
                coordinator.startEmptyWorkout()
            } label: {
                Text("Start Workout")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                coordinator.showRoutineBuilder()
            } label: {
                Text("Create Routine")
            }
            .buttonStyle(.bordered)
        }
    }
}

/// Row view for a single workout in the list
struct WorkoutRowView: View {
    let workout: WorkoutItemViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                Text(workout.formattedDuration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(workout.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("\(workout.exerciseCount)", systemImage: "figure.strengthtraining.traditional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(workout.totalSets)", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
