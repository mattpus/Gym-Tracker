import SwiftUI

struct AppRootView: View {
    let router: MainRouter

    var body: some View {
        router.rootView()
    }
}
