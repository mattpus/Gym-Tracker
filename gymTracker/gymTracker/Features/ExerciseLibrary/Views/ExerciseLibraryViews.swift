import SwiftUI

/// Exercise Library view
struct ExerciseLibraryView: View {
    @Bindable var viewModel: ExerciseLibraryViewModel
    let router: HomeRouter
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.exercises.isEmpty {
                ProgressView("Loading exercises...")
            } else if viewModel.exercises.isEmpty {
                ContentUnavailableView.search
            } else {
                exercisesList
            }
        }
        .navigationTitle("Exercise Library")
        .searchable(text: $viewModel.searchQuery, prompt: "Search exercises")
        .onSubmit(of: .search) {
            viewModel.search()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.showAddCustomExercise()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if viewModel.exercises.isEmpty {
                viewModel.loadExercises()
            }
        }
    }
    
    private var exercisesList: some View {
        List {
            ForEach(viewModel.filteredExercises) { exercise in
                ExerciseLibraryRow(exercise: exercise)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.showExerciseDetail(exerciseId: exercise.id)
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct ExerciseLibraryRow: View {
    let exercise: LibraryExerciseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                if exercise.isCustom {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            
            HStack {
                Label(exercise.primaryMuscleGroup.rawValue, systemImage: "figure.strengthtraining.traditional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label(exercise.equipmentType.rawValue, systemImage: "dumbbell")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Exercise Detail view
struct ExerciseDetailView: View {
    @Bindable var viewModel: ExerciseDetailViewModel
    let router: HomeRouter
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let exercise = viewModel.exercise {
                exerciseDetail(exercise)
            }
        }
        .navigationTitle(viewModel.exercise?.name ?? "Exercise")
        .toolbar {
            if let exercise = viewModel.exercise, exercise.isCustom {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Edit") {
                            router.showEditCustomExercise(exercise)
                        }

                        Button("Delete", role: .destructive) {
                            router.deleteCustomExercise(exercise.id)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadExercise()
        }
    }
    
    private func exerciseDetail(_ exercise: LibraryExerciseItem) -> some View {
        List {
            Section("Primary Muscle") {
                Label(exercise.primaryMuscleGroup.rawValue, systemImage: "figure.strengthtraining.traditional")
            }
            
            if !exercise.secondaryMuscleGroups.isEmpty {
                Section("Secondary Muscles") {
                    ForEach(exercise.secondaryMuscleGroups, id: \.self) { muscle in
                        Text(muscle.rawValue)
                    }
                }
            }
            
            Section("Equipment") {
                Label(exercise.equipmentType.rawValue, systemImage: "dumbbell")
            }
            
            if exercise.isCustom {
                Section {
                    Label("Custom Exercise", systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

/// Add Custom Exercise view
struct AddCustomExerciseView: View {
    @Bindable var viewModel: AddCustomExerciseViewModel
    let router: HomeRouter
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("Name", text: $viewModel.name)
                }
                
                Section("Primary Muscle Group") {
                    Picker("Muscle Group", selection: $viewModel.primaryMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                            Text(muscle.rawValue).tag(muscle)
                        }
                    }
                }
                
                Section("Equipment") {
                    Picker("Equipment Type", selection: $viewModel.equipmentType) {
                        ForEach(EquipmentType.allCases, id: \.self) { equipment in
                            Text(equipment.rawValue).tag(equipment)
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save { success in
                            if success {
                                router.dismissAddCustomExercise()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }
            }
        }
    }
}

struct EditCustomExerciseView: View {
    @Bindable var viewModel: EditCustomExerciseViewModel
    let router: HomeRouter

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Name") {
                    TextField("Name", text: $viewModel.name)
                }

                Section("Primary Muscle Group") {
                    Picker("Muscle Group", selection: $viewModel.primaryMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                            Text(muscle.rawValue).tag(muscle)
                        }
                    }
                }

                Section("Equipment") {
                    Picker("Equipment Type", selection: $viewModel.equipmentType) {
                        ForEach(EquipmentType.allCases, id: \.self) { equipment in
                            Text(equipment.rawValue).tag(equipment)
                        }
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save { success in
                            if success {
                                router.dismissEditCustomExercise()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }
            }
        }
    }
}
