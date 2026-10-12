import SwiftUI
import DesignTokensKit

/// Optional decoration for a surface. It never intercepts input or changes semantics.
public struct SurfaceShadow: Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat
    public init(color: Color = .clear, radius: CGFloat = 0, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color; self.radius = radius; self.x = x; self.y = y
    }
}

/// A generic padded surface. Children retain their own accessibility and interactions.
/// No automatic grouping, tap gesture, model, navigation or fixed height is introduced.
public struct SurfaceCard<Content: View>: View {
    private let metrics: SurfaceMetrics
    private let colors: SemanticColors
    private let cornerStyle: RoundedCornerStyle
    private let clipsContent: Bool
    private let backgroundInsets: EdgeInsets
    private let shadow: SurfaceShadow
    private let content: Content

    public init(
        metrics: SurfaceMetrics = SurfaceMetrics(),
        colors: SemanticColors = SemanticColors(),
        cornerStyle: RoundedCornerStyle = .continuous,
        clipsContent: Bool = false,
        backgroundInsets: EdgeInsets = EdgeInsets(),
        shadow: SurfaceShadow = SurfaceShadow(),
        @ViewBuilder content: () -> Content
    ) {
        self.metrics = metrics; self.colors = colors; self.cornerStyle = cornerStyle
        self.clipsContent = clipsContent; self.backgroundInsets = backgroundInsets
        self.shadow = shadow; self.content = content()
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: metrics.cornerRadius, style: cornerStyle)
    }

    private var surface: some View {
        content
            .padding(metrics.padding)
            .background {
                Group {
                    if clipsContent {
                        // Clip the rectangular fill once with the content. Filling a
                        // rounded shape first would double-antialias its edge.
                        Rectangle().fill(colors.surface)
                    } else {
                        shape.fill(colors.surface)
                    }
                }
                    .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                    .padding(backgroundInsets)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
            .overlay {
                shape.stroke(colors.border, lineWidth: metrics.borderWidth)
                    .padding(backgroundInsets)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
    }

    public var body: some View {
        if clipsContent { surface.clipShape(shape) } else { surface }
    }
}

/// A compact vertical tile with independently composed visual and caption slots.
/// Unlike SurfaceCard, this owns a vertical layout and inter-slot spacing.
/// Supply decorative/accessibility modifiers on the visual where appropriate.
public struct ContentTile<Visual: View, Caption: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let metrics: SurfaceMetrics
    private let colors: SemanticColors
    private let visual: Visual
    private let caption: Caption

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = Spacing.twelve,
        metrics: SurfaceMetrics = SurfaceMetrics(),
        colors: SemanticColors = SemanticColors(),
        @ViewBuilder visual: () -> Visual,
        @ViewBuilder caption: () -> Caption
    ) {
        self.alignment = alignment; self.spacing = spacing
        self.metrics = metrics; self.colors = colors
        self.visual = visual(); self.caption = caption()
    }

    public var body: some View {
        SurfaceCard(metrics: metrics, colors: colors) {
            VStack(alignment: alignment, spacing: spacing) { visual; caption }
        }
    }
}

/// Native Button styling: actions, disabled behavior, roles, labels and focus remain
/// owned by Button. No animation means Reduce Motion needs no special branch.
public struct TokenButtonStyle: ButtonStyle {
    public let metrics: ButtonMetrics
    public let colors: SemanticColors
    @Environment(\.isEnabled) private var isEnabled

    public init(metrics: ButtonMetrics = ButtonMetrics(), colors: SemanticColors = SemanticColors()) {
        self.metrics = metrics; self.colors = colors
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(metrics.padding)
            .frame(minWidth: metrics.minimumWidth, minHeight: metrics.minimumHeight)
            .foregroundStyle(colors.onAction)
            .background(RoundedRectangle(cornerRadius: metrics.cornerRadius).fill(colors.action))
            .contentShape(RoundedRectangle(cornerRadius: metrics.cornerRadius))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.5)
    }
}
