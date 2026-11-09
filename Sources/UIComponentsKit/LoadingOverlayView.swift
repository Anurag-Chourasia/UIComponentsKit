import SwiftUI
import DesignTokensKit
import LocalizationKit

public struct LoadingOverlayView: View {
    private let message: String

    public init(messageKeyPath: KeyPath<CommonStrings, String>, context: CommonStrings = .shared) {
        self.message = context[keyPath: messageKeyPath]
    }

    public init(message: String) { self.message = message }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(\.black, opacity: \.p0_35)
                .ignoresSafeArea()

            VStack(spacing: \.twelve) {
                ProgressView()
                Text(message)
                    .font(\.footnote)
                    .foregroundStyle(\.secondary)
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
