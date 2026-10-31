import SwiftUI
import DesignTokensKit

/// App-supplied component metrics and colors. Existing unthemed components retain
/// their explicit initializer behaviour; opt in with ThemedSurface/ThemedButtonStyle.
public struct ComponentTheme: Sendable {
    public var surface: SurfaceMetrics
    public var button: ButtonMetrics
    public var colors: SemanticColors
    public init(surface: SurfaceMetrics = .init(), button: ButtonMetrics = .init(),
                colors: SemanticColors = .init()) {
        self.surface = surface; self.button = button; self.colors = colors
    }
}

private struct ComponentThemeKey: EnvironmentKey {
    static let defaultValue = ComponentTheme()
}

public extension EnvironmentValues {
    var componentTheme: ComponentTheme {
        get { self[ComponentThemeKey.self] }
        set { self[ComponentThemeKey.self] = newValue }
    }
}

public extension View {
    func componentTheme(_ theme: ComponentTheme) -> some View {
        environment(\.componentTheme, theme)
    }
}

public struct ThemedSurface<Content: View>: View {
    @Environment(\.componentTheme) private var theme
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        SurfaceCard(metrics: theme.surface, colors: theme.colors) { content }
    }
}

public struct ThemedButtonStyle: ButtonStyle {
    @Environment(\.componentTheme) private var theme
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        TokenButtonStyle(metrics: theme.button, colors: theme.colors).makeBody(configuration: configuration)
    }
}
