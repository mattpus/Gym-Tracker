import XCTest
@testable import ProgressionDomain

final class UserProfileTests: XCTestCase {
    
    func test_defaultProfile_hasIntermediateLevelAndStrengthGoal() {
        let profile = UserProfile.default
        
        XCTAssertEqual(profile.experienceLevel, .intermediate)
        XCTAssertEqual(profile.primaryGoal, .strength)
        XCTAssertEqual(profile.recoveryCapacity, .average)
    }
    
    func test_experienceLevel_hasCorrectProgressionRates() {
        XCTAssertEqual(ExperienceLevel.beginner.weeklyProgressionRate, 0.05)
        XCTAssertEqual(ExperienceLevel.intermediate.weeklyProgressionRate, 0.025)
        XCTAssertEqual(ExperienceLevel.advanced.weeklyProgressionRate, 0.01)
        XCTAssertEqual(ExperienceLevel.elite.weeklyProgressionRate, 0.005)
    }
    
    func test_trainingGoal_hasCorrectRepRanges() {
        XCTAssertEqual(TrainingGoal.strength.targetRepRange, 1...5)
        XCTAssertEqual(TrainingGoal.hypertrophy.targetRepRange, 8...12)
        XCTAssertEqual(TrainingGoal.endurance.targetRepRange, 15...20)
    }
    
    func test_recoveryCapacity_hasCorrectRestDays() {
        XCTAssertEqual(RecoveryCapacity.low.suggestedRestDays, 3)
        XCTAssertEqual(RecoveryCapacity.average.suggestedRestDays, 2)
        XCTAssertEqual(RecoveryCapacity.high.suggestedRestDays, 1)
    }
}
