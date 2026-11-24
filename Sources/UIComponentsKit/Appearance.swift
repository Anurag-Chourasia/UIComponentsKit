import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Application appearance modes (system, light, dark).
/// Shared across host applications and stored in standard `@AppStorage`.
public enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    #if canImport(UIKit)
    public var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    #endif
}

#if canImport(UIKit)
/// Apply to a scene's window hierarchy so navigation destinations, sheets and menus inherit it.
/// `.unspecified` restores the current system style, including after an override.
public struct WindowAppearance: UIViewRepresentable {
    public let style: UIUserInterfaceStyle

    public init(style: UIUserInterfaceStyle) {
        self.style = style
    }

    public func makeUIView(context: Context) -> AppearanceView {
        AppearanceView()
    }

    public func updateUIView(_ view: AppearanceView, context: Context) {
        view.style = style
    }

    public final class AppearanceView: UIView {
        var style: UIUserInterfaceStyle = .unspecified {
            didSet { apply() }
        }

        public override func didMoveToWindow() {
            super.didMoveToWindow()
            apply()
        }

        private func apply() {
            guard let window else { return }
            if window.overrideUserInterfaceStyle != style {
                window.overrideUserInterfaceStyle = style
            }
            window.rootViewController?.overrideUserInterfaceStyle = style
            if let windowScene = window.windowScene {
                for win in windowScene.windows {
                    if win.overrideUserInterfaceStyle != style {
                        win.overrideUserInterfaceStyle = style
                    }
                    win.rootViewController?.overrideUserInterfaceStyle = style
                }
            }
        }
    }
}

public struct AppAppearanceModifier: ViewModifier {
    @AppStorage("appAppearance") private var selection: AppAppearance = .system

    public init() {}

    public func body(content: Content) -> some View {
        content
            .preferredColorScheme(selection.colorScheme)
            .background(WindowAppearance(style: selection.interfaceStyle).allowsHitTesting(false))
    }
}

extension View {
    public func appAppearance() -> some View {
        modifier(AppAppearanceModifier())
    }

    @ViewBuilder
    public func applyModalSheetStyle(background: Color = BrandPalette.current.background) -> some View {
        #if os(iOS)
        if #available(iOS 16.4, *) {
            self
                .presentationBackground(background)
                .presentationDragIndicator(.visible)
                .appAppearance()
        } else {
            self
                .appAppearance()
        }
        #else
        self
        #endif
    }
}
#endif
