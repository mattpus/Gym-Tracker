import SwiftUI

struct RoutineBuilderView: View {
    @Bindable var viewModel: RoutineBuilderViewModel
    @Bindable var router: WorkoutsRouter
    
    var body: some View {
        NavigationStack {
            List {
                Section("Routine Name") {
                    TextField("Push Day", text: $viewModel.name)
                        .accessibilityIdentifier("routineNameField")
                }
                
                Section {
                    Button {
                        router.showRoutineBuilderExerciseSelection()
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addRoutineExerciseButton")
                }
                
                Section("Exercises") {
                    if viewModel.selectedExercises.isEmpty {
                        Text("No exercises added yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.selectedExercises) { exercise in
                            Text(exercise.name)
                        }
                        .onDelete(perform: viewModel.removeExercises)
                        .onMove(perform: viewModel.moveExercises)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        router.dismissRoutineBuilder()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        viewModel.save { saved in
                            if saved {
                                router.didSaveRoutine()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                    .accessibilityIdentifier("saveRoutineButton")
                }
                
                if !viewModel.selectedExercises.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }
}
