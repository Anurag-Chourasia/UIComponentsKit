import SwiftUI
import DesignTokensKit
import LocalizationKit

/// Standard offline banner built on top of IconMessageBanner.
public struct OfflineBannerView: View {
    private let message: String
    private let isWarning: Bool
    private let backgroundColor: Color

    public init(
        messageKeyPath: KeyPath<CommonStrings, String>,
        isWarning: Bool = true,
        backgroundColor: KeyPath<ColorTheme, Color> = \.red,
        context: CommonStrings = .shared,
        colorTheme: ColorTheme = .default
    ) {
        self.message = context[keyPath: messageKeyPath]
        self.isWarning = isWarning
        self.backgroundColor = colorTheme[keyPath: backgroundColor]
    }

    public init(
        message: String,
        isWarning: Bool = true,
        backgroundColor: KeyPath<ColorTheme, Color> = \.red,
        colorTheme: ColorTheme = .default
    ) {
        self.message = message
        self.isWarning = isWarning
        self.backgroundColor = colorTheme[keyPath: backgroundColor]
    }

    public init(
        message: String,
        isWarning: Bool = true,
        backgroundColor: Color
    ) {
        self.message = message
        self.isWarning = isWarning
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        IconMessageBanner(
            padding: \.eight,
            font: \.caption,
            foreground: \.white,
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
        titleKeyPath: KeyPath<CommonStrings, String>,
        messageKeyPath: KeyPath<CommonStrings, String>,
        context: CommonStrings = .shared,
        @ViewBuilder actions: () -> Actions
    ) {
        self.symbol = symbol
        self.title = context[keyPath: titleKeyPath]
        self.message = context[keyPath: messageKeyPath]
        self.actions = actions()
    }

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
            },
            title: {
                Text(title)
            },
            detail: {
                Text(message)
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
        titleKeyPath: KeyPath<CommonStrings, String>,
        messageKeyPath: KeyPath<CommonStrings, String>,
        context: CommonStrings = .shared
    ) {
        self.init(
            symbol: symbol,
            titleKeyPath: titleKeyPath,
            messageKeyPath: messageKeyPath,
            context: context,
            actions: { EmptyView() }
        )
    }

    public init(
        symbol: KeyPath<SymbolTheme, AppSymbol>,
        title: String,
        message: String
    ) {
        self.init(symbol: symbol, title: title, message: message, actions: { EmptyView() })
    }
}
