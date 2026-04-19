import XCTest
@testable import gymTracker

final class ExerciseLibraryDomainTests: XCTestCase {
	func testAddCustomExerciseMarksExerciseAsCustomAndSavesIt() throws {
		let repository = ExerciseLibraryRepositorySpy()
		let sut = AddCustomExerciseUseCase(repository: repository)
		let exercise = LibraryExercise(
			id: UUID(),
			name: "My Custom Row",
			primaryMuscleGroup: .back,
			secondaryMuscleGroups: [.biceps],
			equipmentType: .cable,
			isCustom: false
		)

		try sut.add(exercise)

		XCTAssertEqual(repository.storedExercises.count, 1)
		XCTAssertEqual(repository.storedExercises.first?.isCustom, true)
		XCTAssertEqual(repository.storedExercises.first?.name, "My Custom Row")
	}

	func testAddCustomExerciseRejectsDuplicateNamesCaseInsensitively() {
		let repository = ExerciseLibraryRepositorySpy(storedExercises: [
			LibraryExercise(id: UUID(), name: "Bench Press", primaryMuscleGroup: .chest, secondaryMuscleGroups: [], equipmentType: .barbell, isCustom: false)
		])
		let sut = AddCustomExerciseUseCase(repository: repository)

		XCTAssertThrowsError(try sut.add(LibraryExercise(id: UUID(), name: "bench press", primaryMuscleGroup: .chest, secondaryMuscleGroups: [], equipmentType: .barbell, isCustom: true)))
	}
}
