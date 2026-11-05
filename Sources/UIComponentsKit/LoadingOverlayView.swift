import SwiftUI
import DesignTokensKit

public struct LoadingOverlayView: View {
    private let message: String

    public init(message: String) { self.message = message }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(\.black, opacity: \.p0_35)
                .ignoresSafeArea()

            VStack(spacing: \.twelve) {
                ProgressView()
                Text(message)
                    .font(Typography.footnote)
                    .foregroundColor(\.secondary)
            }
            .padding(\.twenty)
            .background(.ultraThinMaterial)
            .cornerRadius(\.twelve)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(message))

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
}
