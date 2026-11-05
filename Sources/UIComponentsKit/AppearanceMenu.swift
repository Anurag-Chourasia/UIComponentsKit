import SwiftUI
import DesignTokensKit

/// Shared appearance control. Hosts supply localized copy and optional feedback.
public struct AppearanceMenu: View {
    @AppStorage("appAppearance") private var selection: AppAppearance = .system
    private let title: String
    private let systemTitle: String
    private let lightTitle: String
    private let darkTitle: String
    private let iconOnly: Bool
    private let onSelection: () -> Void

    public init(title: String, systemTitle: String, lightTitle: String, darkTitle: String,
                iconOnly: Bool = false, onSelection: @escaping () -> Void = {}) {
        self.title = title
        self.systemTitle = systemTitle
        self.lightTitle = lightTitle
        self.darkTitle = darkTitle
        self.iconOnly = iconOnly
        self.onSelection = onSelection
    }

    public var body: some View {
        Menu {
            ForEach(AppAppearance.allCases) { appearance in
                Button {
                    guard selection != appearance else { return }
                    selection = appearance
                    onSelection()
                } label: {
                    if selection == appearance { Label(label(for: appearance), \.checkmark) } else { Text(label(for: appearance)) }
                }
            }
        } label: {
            if iconOnly { Image(\.circleLefthalfFilled) } else { Label(title, \.circleLefthalfFilled) }
        }
        .accessibilityLabel(title)
        .accessibilityIdentifier(.appearanceMenu)
    }

    private func label(for appearance: AppAppearance) -> String {
        switch appearance {
        case .system: systemTitle
        case .light: lightTitle
        case .dark: darkTitle
        }
    }
}
