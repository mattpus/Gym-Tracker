import Foundation
import Observation

/// Stores navigation state for one visible navigation container.
@Observable
@MainActor
final class NavigationRouter {
    let id = UUID()
    let level: Int
    let tab: AppTab?

    var path: [PushDestination] = []
    var presentingSheet: SheetDestination?
    var presentingFullScreen: FullScreenDestination?

    weak var parent: NavigationRouter?
    weak var mainRouter: MainRouter?
    private(set) var isActive = false

    init(level: Int, tab: AppTab?, mainRouter: MainRouter? = nil) {
        self.level = level
        self.tab = tab
        self.mainRouter = mainRouter
    }

    func childRouter() -> NavigationRouter {
        let router = NavigationRouter(level: level + 1, tab: tab, mainRouter: mainRouter)
        router.parent = self
        return router
    }

    func setActive() {
        parent?.resignActive()
        isActive = true
    }

    func resignActive() {
        isActive = false
    }

    func navigate(to destination: Destination) {
        switch destination {
        case .tab(let tab):
            select(tab: tab)
        case .push(let destination):
            push(destination)
        case .sheet(let destination):
            present(sheet: destination)
        case .fullScreen(let destination):
            present(fullScreen: destination)
        }
    }

    func select(tab destination: AppTab) {
        mainRouter?.selectedTab = destination
        if level > 1 {
            resetContent()
        }
    }

    func push(_ destination: PushDestination) {
        path.append(destination)
    }

    func present(sheet destination: SheetDestination) {
        presentingSheet = destination
    }

    func present(fullScreen destination: FullScreenDestination) {
        presentingFullScreen = destination
    }

    func dismissSheet() {
        presentingSheet = nil
    }

    func dismissFullScreen() {
        presentingFullScreen = nil
    }

    func deepLinkOpen(to destination: Destination) {
        guard isActive else { return }
        navigate(to: destination)
    }

    func resetContent() {
        path = []
        presentingSheet = nil
        presentingFullScreen = nil
    }
}
