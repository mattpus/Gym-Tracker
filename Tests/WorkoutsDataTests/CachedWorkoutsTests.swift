import XCTest
@testable import WorkoutsData

final class CachedWorkoutsTests: XCTestCase {
	func test_init_setsAllProperties() {
		let workouts = [makeWorkout().local]
		let timestamp = Date()
		
		let sut = CachedWorkouts(workouts: workouts, timestamp: timestamp)
		
		XCTAssertEqual(sut.workouts, workouts)
		XCTAssertEqual(sut.timestamp, timestamp)
	}
}
