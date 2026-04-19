import XCTest
@testable import gymTracker

@MainActor
final class SettingsAndEditingTests: XCTestCase {
    func testEditWorkoutUpdatesLastUpdatedAtAndPreservesFinishedState() {
        let originalDate = Date(timeIntervalSince1970: 100)
        let workout = Workout(
            id: UUID(),
            date: originalDate,
            lastUpdatedAt: originalDate,
            isFinished: true,
            name: "Push",
            exercises: []
        )
        let repository = WorkoutRepositorySpy(storedWorkouts: [workout])
        let sut = EditWorkoutUseCase(repository: repository)

        let exp = expectation(description: "edit workout")
        sut.edit(Workout(id: workout.id, date: originalDate, lastUpdatedAt: originalDate, isFinished: true, name: "Push Updated", exercises: [])) { result in
            XCTAssertNoThrow(try? result.get())
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(repository.storedWorkouts.first?.name, "Push Updated")
        XCTAssertEqual(repository.storedWorkouts.first?.isFinished, true)
        XCTAssertNotEqual(repository.storedWorkouts.first?.lastUpdatedAt, originalDate)
    }

    func testDeleteCustomExerciseDeletesOnlyCustomExercise() throws {
        let custom = LibraryExercise(id: UUID(), name: "My Row", primaryMuscleGroup: .back, equipmentType: .cable, isCustom: true)
        let builtIn = LibraryExercise(id: UUID(), name: "Bench Press", primaryMuscleGroup: .chest, equipmentType: .barbell, isCustom: false)
        let repository = ExerciseLibraryRepositorySpy(storedExercises: [custom, builtIn])
        let sut = DeleteCustomExerciseUseCase(repository: repository)

        try sut.delete(exerciseId: custom.id)

        XCTAssertEqual(repository.storedExercises.map(\.name), ["Bench Press"])
    }

    func testDeleteCustomExerciseRejectsBuiltInExercise() {
        let builtIn = LibraryExercise(id: UUID(), name: "Bench Press", primaryMuscleGroup: .chest, equipmentType: .barbell, isCustom: false)
        let repository = ExerciseLibraryRepositorySpy(storedExercises: [builtIn])
        let sut = DeleteCustomExerciseUseCase(repository: repository)

        XCTAssertThrowsError(try sut.delete(exerciseId: builtIn.id))
    }

    func testDataSettingsViewModelExportsFinishedWorkoutRowsOnly() {
        let finished = Workout(
            date: Date(timeIntervalSince1970: 0),
            lastUpdatedAt: Date(timeIntervalSince1970: 0),
            isFinished: true,
            name: "Push",
            exercises: [Exercise(name: "Bench", sets: [ExerciseSet(order: 0, type: .main, repetitions: 8, weight: 60, isCompleted: true)])]
        )
        let active = Workout(
            date: Date(timeIntervalSince1970: 10),
            lastUpdatedAt: Date(timeIntervalSince1970: 10),
            isFinished: false,
            name: "Active",
            exercises: []
        )
        let repository = WorkoutRepositorySpy(storedWorkouts: [finished, active])
        let viewModel = DataSettingsViewModel(
            exportUseCase: ExportWorkoutHistoryCSVUseCase(repository: repository),
            deleteHistoryUseCase: DeleteWorkoutHistoryUseCase(repository: repository)
        )

        viewModel.prepareExport()

        XCTAssertNotNil(viewModel.exportCSV)
        XCTAssertTrue(viewModel.exportCSV?.contains("Push") == true)
        XCTAssertFalse(viewModel.exportCSV?.contains("Active") == true)
    }

    func testDataSettingsViewModelDeleteClearsWorkouts() {
        let repository = WorkoutRepositorySpy(storedWorkouts: [Workout(date: Date(), name: "Push", exercises: [])])
        let viewModel = DataSettingsViewModel(
            exportUseCase: ExportWorkoutHistoryCSVUseCase(repository: repository),
            deleteHistoryUseCase: DeleteWorkoutHistoryUseCase(repository: repository)
        )

        let exp = expectation(description: "delete")
        viewModel.deleteAllData { success in
            XCTAssertTrue(success)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        XCTAssertTrue(repository.storedWorkouts.isEmpty)
    }
}
