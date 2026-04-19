import XCTest
@testable import gymTracker

@MainActor
final class RouterTests: XCTestCase {
    func testChildRouterInheritsTabIdentity() {
        let parent = NavigationRouter(level: 1, tab: .home)

        let child = parent.childRouter()

        XCTAssertEqual(child.level, 2)
        XCTAssertEqual(child.tab, .home)
        XCTAssertTrue(child.parent === parent)
    }

    func testChildRouterBecomesActiveAndParentResigns() {
        let parent = NavigationRouter(level: 1, tab: .home)
        let child = parent.childRouter()
        parent.setActive()

        child.setActive()

        XCTAssertFalse(parent.isActive)
        XCTAssertTrue(child.isActive)
    }

    func testSelectingTabBubblesToMainRouterAndClearsChildState() {
        let mainRouter = MainRouter(container: DependencyContainer())
        let child = mainRouter.homeRouter.navigation.childRouter()
        child.push(.exerciseLibrary)
        child.present(sheet: .addCustomExercise)
        child.present(fullScreen: .activeWorkout(id: UUID()))

        child.select(tab: .workouts)

        XCTAssertEqual(mainRouter.selectedTab, .workouts)
        XCTAssertTrue(child.path.isEmpty)
        XCTAssertNil(child.presentingSheet)
        XCTAssertNil(child.presentingFullScreen)
    }

    func testInactiveRouterIgnoresDeepLinkOpen() {
        let router = NavigationRouter(level: 1, tab: .home)

        router.deepLinkOpen(to: .push(.exerciseLibrary))

        XCTAssertTrue(router.path.isEmpty)
    }

    func testActiveRouterHandlesDeepLinkDestinations() {
        let router = NavigationRouter(level: 1, tab: .workouts)
        let workoutID = UUID()
        router.setActive()

        router.deepLinkOpen(to: .push(.workoutDetail(id: workoutID)))
        router.deepLinkOpen(to: .sheet(.routineSelection))
        router.deepLinkOpen(to: .fullScreen(.activeWorkout(id: workoutID)))

        XCTAssertEqual(router.path, [.workoutDetail(id: workoutID)])
        XCTAssertEqual(router.presentingSheet, .routineSelection)
        XCTAssertEqual(router.presentingFullScreen, .activeWorkout(id: workoutID))
    }

    func testDeepLinkHookReturnsNilForUnsupportedURL() throws {
        let url = try XCTUnwrap(URL(string: "gymtracker://workouts"))

        XCTAssertNil(DeepLink.destination(from: url))
    }
}
