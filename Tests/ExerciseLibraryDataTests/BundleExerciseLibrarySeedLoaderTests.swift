import XCTest
@testable import ExerciseLibraryData
@testable import ExerciseLibraryDomain

final class BundleExerciseLibrarySeedLoaderTests: XCTestCase {
    
    func test_loadSeedExercises_loadsFromBundle() throws {
        let sut = BundleExerciseLibrarySeedLoader()
        
        let exercises = try sut.loadSeedExercises()
        
        XCTAssertGreaterThan(exercises.count, 90)
    }
    
    func test_loadSeedExercises_containsExpectedExercises() throws {
        let sut = BundleExerciseLibrarySeedLoader()
        
        let exercises = try sut.loadSeedExercises()
        
        XCTAssertTrue(exercises.contains { $0.name == "Barbell Bench Press" })
        XCTAssertTrue(exercises.contains { $0.name == "Barbell Back Squat" })
        XCTAssertTrue(exercises.contains { $0.name == "Conventional Deadlift" })
    }
    
    func test_loadSeedExercises_exercisesHaveCorrectMuscleGroups() throws {
        let sut = BundleExerciseLibrarySeedLoader()
        
        let exercises = try sut.loadSeedExercises()
        
        let benchPress = exercises.first { $0.name == "Barbell Bench Press" }
        XCTAssertEqual(benchPress?.primaryMuscleGroup, .chest)
        XCTAssertTrue(benchPress?.secondaryMuscleGroups.contains(.triceps) ?? false)
    }
    
    func test_loadSeedExercises_allExercisesAreNotCustom() throws {
        let sut = BundleExerciseLibrarySeedLoader()
        
        let exercises = try sut.loadSeedExercises()
        
        XCTAssertTrue(exercises.allSatisfy { !$0.isCustom })
    }
    
    func test_loadSeedExercises_coversAllEquipmentTypes() throws {
        let sut = BundleExerciseLibrarySeedLoader()
        
        let exercises = try sut.loadSeedExercises()
        let equipmentTypes = Set(exercises.map(\.equipmentType))
        
        XCTAssertTrue(equipmentTypes.contains(.barbell))
        XCTAssertTrue(equipmentTypes.contains(.dumbbell))
        XCTAssertTrue(equipmentTypes.contains(.machine))
        XCTAssertTrue(equipmentTypes.contains(.cable))
        XCTAssertTrue(equipmentTypes.contains(.bodyweight))
        XCTAssertTrue(equipmentTypes.contains(.kettlebell))
        XCTAssertTrue(equipmentTypes.contains(.band))
    }
}
