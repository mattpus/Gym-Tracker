import SwiftUI

struct NavigationButton<Content: View>: View {
    private let destination: Destination
    @ViewBuilder private let content: () -> Content
    @Environment(NavigationRouter.self) private var router

    init(destination: Destination, @ViewBuilder content: @escaping () -> Content) {
        self.destination = destination
        self.content = content
    }

    init(push destination: PushDestination, @ViewBuilder content: @escaping () -> Content) {
        self.destination = .push(destination)
        self.content = content
    }

    init(sheet destination: SheetDestination, @ViewBuilder content: @escaping () -> Content) {
        self.destination = .sheet(destination)
        self.content = content
    }

    init(fullScreen destination: FullScreenDestination, @ViewBuilder content: @escaping () -> Content) {
        self.destination = .fullScreen(destination)
        self.content = content
    }

    var body: some View {
        Button(action: { router.navigate(to: destination) }) {
            content()
        }
    }
}
