import SwiftUI

/// Shared root container for scroll-based screens.
/// It keeps the scene feeling full screen while constraining readable content on wider devices.
struct AppScrollScreen<Content: View>: View {
    private let spacing: CGFloat
    @ViewBuilder private let content: () -> Content

    init(
        spacing: CGFloat = 20,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: spacing) {
                    content()
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: geometry.size.height,
                    alignment: .topLeading
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appScreenBackground()
        }
    }
}

private struct AppScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .systemGroupedBackground))
    }
}

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackgroundModifier())
    }
}
