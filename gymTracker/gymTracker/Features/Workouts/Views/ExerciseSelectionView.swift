import SwiftUI

/// View for selecting an exercise from the library to add to a workout
struct ExerciseSelectionView: View {
    @Bindable var viewModel: ExerciseSelectionViewModel
    let onExerciseSelected: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Muscle Group Filter Chips
                muscleGroupFilters
                
                // Exercise List
                exerciseList
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadExercises()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search exercises...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchQuery) { _, _ in
                    viewModel.search()
                }
            
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                    viewModel.search()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
        .accessibilityIdentifier("exerciseSearchField")
    }
    
    // MARK: - Muscle Group Filters
    
    private var muscleGroupFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedMuscleGroup == nil,
                    color: .gray
                ) {
                    viewModel.filterByMuscleGroup(nil)
                }
                
                // Muscle group chips
                ForEach(viewModel.availableMuscleGroups, id: \.self) { muscleGroup in
                    FilterChip(
                        title: muscleGroup.displayName,
                        isSelected: viewModel.selectedMuscleGroup == muscleGroup,
                        color: muscleGroup.color
                    ) {
                        viewModel.filterByMuscleGroup(muscleGroup)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .accessibilityIdentifier("muscleGroupFilter")
    }
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading exercises...")
            } else if viewModel.filteredExercises.isEmpty {
                ContentUnavailableView {
                    Label("No Exercises Found", systemImage: "dumbbell")
                } description: {
                    Text("Try adjusting your search or filters")
                }
            } else {
                List(viewModel.filteredExercises) { exercise in
                    ExerciseRow(exercise: exercise)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let workoutExercise = viewModel.createWorkoutExercise(from: exercise)
                            onExerciseSelected(workoutExercise)
                            dismiss()
                        }
                        .accessibilityIdentifier("exerciseRow_\(exercise.id)")
                }
                .listStyle(.plain)
                .accessibilityIdentifier("exerciseList")
            }
        }
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: SelectableExerciseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise Name
            Text(exercise.name)
                .font(.headline)
            
            // Muscle Group Tags
            HStack(spacing: 6) {
                MuscleGroupTag(
                    muscleGroup: exercise.primaryMuscleGroup,
                    isPrimary: true
                )
                
                ForEach(exercise.secondaryMuscleGroups, id: \.self) { muscleGroup in
                    MuscleGroupTag(
                        muscleGroup: muscleGroup,
                        isPrimary: false
                    )
                }
            }
            
            // Equipment Type
            HStack(spacing: 4) {
                Image(systemName: exercise.equipmentType.iconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(exercise.equipmentType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Muscle Group Tag

private struct MuscleGroupTag: View {
    let muscleGroup: MuscleGroup
    let isPrimary: Bool
    
    var body: some View {
        Text(muscleGroup.displayName)
            .font(.caption2)
            .fontWeight(isPrimary ? .semibold : .regular)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(muscleGroup.color.opacity(isPrimary ? 0.2 : 0.1))
            .foregroundStyle(muscleGroup.color)
            .clipShape(Capsule())
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
                .foregroundStyle(isSelected ? color : .secondary)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color : Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - MuscleGroup Extensions

extension MuscleGroup {
    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .forearms: return "Forearms"
        case .quadriceps: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .glutes: return "Glutes"
        case .calves: return "Calves"
        case .core: return "Core"
        case .traps: return "Traps"
        case .lats: return "Lats"
        }
    }
    
    var color: Color {
        switch self {
        case .chest: return .red
        case .back: return .blue
        case .shoulders: return .orange
        case .biceps: return .purple
        case .triceps: return .pink
        case .forearms: return .brown
        case .quadriceps: return .green
        case .hamstrings: return .teal
        case .glutes: return .indigo
        case .calves: return .mint
        case .core: return .yellow
        case .traps: return .cyan
        case .lats: return .blue.opacity(0.7)
        }
    }
}

// MARK: - EquipmentType Extensions

extension EquipmentType {
    var displayName: String {
        switch self {
        case .barbell: return "Barbell"
        case .dumbbell: return "Dumbbell"
        case .cable: return "Cable"
        case .machine: return "Machine"
        case .bodyweight: return "Bodyweight"
        case .kettlebell: return "Kettlebell"
        case .band: return "Resistance Band"
        }
    }
    
    var iconName: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .cable: return "cable.connector"
        case .machine: return "gearshape.fill"
        case .bodyweight: return "figure.walk"
        case .kettlebell: return "figure.strengthtraining.functional"
        case .band: return "circle.dotted"
        }
    }
}
