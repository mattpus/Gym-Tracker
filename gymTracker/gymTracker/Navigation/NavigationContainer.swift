import SwiftUI

struct NavigationContainer<Content: View>: View {
    let mainRouter: MainRouter
    @State private var router: NavigationRouter
    @ViewBuilder private let content: () -> Content

    init(mainRouter: MainRouter, router: NavigationRouter, @ViewBuilder content: @escaping () -> Content) {
        self.mainRouter = mainRouter
        self._router = State(initialValue: router)
        self.content = content
    }

    init(mainRouter: MainRouter, parentRouter: NavigationRouter, @ViewBuilder content: @escaping () -> Content) {
        self.mainRouter = mainRouter
        self._router = State(initialValue: parentRouter.childRouter())
        self.content = content
    }

    var body: some View {
        InnerNavigationContainer(mainRouter: mainRouter, router: router, content: content)
            .environment(router)
            .onAppear(perform: router.setActive)
            .onDisappear(perform: router.resignActive)
            .onOpenURL(perform: openDeepLinkIfFound(for:))
    }

    private func openDeepLinkIfFound(for url: URL) {
        if let destination = DeepLink.destination(from: url) {
            router.deepLinkOpen(to: destination)
        }
    }
}

private struct InnerNavigationContainer<Content: View>: View {
    let mainRouter: MainRouter
    @Bindable var router: NavigationRouter
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: PushDestination.self) { destination in
                    mainRouter.view(for: destination)
                }
        }
        .sheet(item: $router.presentingSheet) { sheet in
            NavigationContainer(mainRouter: mainRouter, parentRouter: router) {
                mainRouter.view(for: sheet)
            }
        }
        .fullScreenCover(item: $router.presentingFullScreen) { fullScreen in
            NavigationContainer(mainRouter: mainRouter, parentRouter: router) {
                mainRouter.view(for: fullScreen)
            }
        }
    }
}
