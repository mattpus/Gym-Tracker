import XCTest
import WorkoutsDomain
@testable import WorkoutsData

final class LocalWorkoutMapperTests: XCTestCase {
	func test_toLocal_encodesDomainWorkouts() {
		let workout = makeWorkout()
		
		let local = [workout.model].toLocal()
		
		XCTAssertEqual(local, [workout.local])
	}
	
	func test_toModels_decodesLocalWorkouts() {
		let workout = makeWorkout()
		
		let models = [workout.local].toModels()
		
		XCTAssertEqual(models, [workout.model])
	}
}
