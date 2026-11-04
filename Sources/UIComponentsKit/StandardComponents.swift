import SwiftUI
import DesignTokensKit

/// Standard offline banner built on top of IconMessageBanner.
public struct OfflineBannerView: View {
    private let message: String
    private let isWarning: Bool
    private let backgroundColor: Color

    public init(
        message: String,
        isWarning: Bool = true,
        backgroundColor: Color = ColorTheme.default.red
    ) {
        self.message = message
        self.isWarning = isWarning
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        IconMessageBanner(
            padding: SpacingTheme.default.eight,
            font: .caption,
            foreground: ColorTheme.default.white,
            icon: {
                Image(isWarning ? \.wifiSlash : \.wifi)
            },
            message: {
                Text(message)
            },
            background: {
                backgroundColor
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(message))
    }
}

/// Full empty-state composition with icon, title, message and optional action.
public struct EmptyStateMessageView<Actions: View>: View {
    private let symbol: KeyPath<SymbolTheme, AppSymbol>
    private let title: String
    private let message: String
    private let actions: Actions

    public init(
        symbol: KeyPath<SymbolTheme, AppSymbol>,
        title: String,
        message: String,
        @ViewBuilder actions: () -> Actions
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actions = actions()
    }

    public var body: some View {
        StateMessage(
            spacing: \.sixteen,
            icon: {
                Image(symbol)
                    .font(.system(size: 48))
                    .foregroundColor(\.secondary)
            },
            title: {
                Text(title)
                    .font(\.headline)
                    .foregroundColor(\.primary)
            },
            detail: {
                Text(message)
                    .font(\.subheadline)
                    .foregroundColor(\.secondary)
            },
            actions: {
                actions
            }
        )
    }
}

extension EmptyStateMessageView where Actions == EmptyView {
    public init(
        symbol: KeyPath<SymbolTheme, AppSymbol>,
        title: String,
        message: String
    ) {
        self.init(symbol: symbol, title: title, message: message, actions: { EmptyView() })
    }
}
