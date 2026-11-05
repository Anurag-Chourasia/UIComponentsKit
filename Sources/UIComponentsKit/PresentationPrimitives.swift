import SwiftUI
import DesignTokensKit

/// Status-message composition with caller-owned content and optional actions.
/// Grouping, outer sizing and localization remain at the call site.
public struct StateMessage<Icon: View, Title: View, Detail: View, Actions: View>: View {
    private let spacing: CGFloat
    private let typography: MessageTypography
    private let detailColor: Color
    private let icon: Icon
    private let title: Title
    private let detail: Detail
    private let actions: Actions

    public init(spacing: CGFloat = Spacing.sixteen,
                typography: MessageTypography = MessageTypography(),
                detailColor: Color = .secondary,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder title: () -> Title,
                @ViewBuilder detail: () -> Detail,
                @ViewBuilder actions: () -> Actions) {
        self.spacing = spacing; self.typography = typography; self.detailColor = detailColor
        self.icon = icon(); self.title = title(); self.detail = detail(); self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            icon.font(typography.icon).accessibilityHidden(true)
            title.font(typography.title)
            detail.font(typography.detail).foregroundColor(detailColor).multilineTextAlignment(.center)
            actions
        }
    }
}

extension StateMessage where Actions == EmptyView {
    public init(spacing: CGFloat = Spacing.sixteen,
                typography: MessageTypography = MessageTypography(),
                detailColor: Color = .secondary,
                @ViewBuilder icon: () -> Icon,
                @ViewBuilder title: () -> Title,
                @ViewBuilder detail: () -> Detail) {
        self.init(spacing: spacing, typography: typography, detailColor: detailColor,
                  icon: icon, title: title, detail: detail, actions: { EmptyView() })
    }

    public init(
        spacing: KeyPath<SpacingTheme, CGFloat>,
        detailColor: KeyPath<ColorTheme, Color> = \.secondary,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title,
        @ViewBuilder detail: () -> Detail,
        spacingTheme: SpacingTheme = .default,
        colorTheme: ColorTheme = .default
    ) {
        self.init(
            spacing: spacingTheme[keyPath: spacing],
            typography: MessageTypography(),
            detailColor: colorTheme[keyPath: detailColor],
            icon: icon,
            title: title,
            detail: detail,
            actions: { EmptyView() }
        )
    }
}

extension StateMessage {
    public init(
        spacing: KeyPath<SpacingTheme, CGFloat>,
        detailColor: KeyPath<ColorTheme, Color> = \.secondary,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title,
        @ViewBuilder detail: () -> Detail,
        @ViewBuilder actions: () -> Actions,
        spacingTheme: SpacingTheme = .default,
        colorTheme: ColorTheme = .default
    ) {
        self.init(
            spacing: spacingTheme[keyPath: spacing],
            typography: MessageTypography(),
            detailColor: colorTheme[keyPath: detailColor],
            icon: icon,
            title: title,
            detail: detail,
            actions: actions
        )
    }
}

/// Full-width notice composition. Decorative icon is hidden; callers own message semantics.
public struct IconMessageBanner<Icon: View, Message: View, Background: View>: View {
    private let spacing: CGFloat?
    private let padding: CGFloat
    private let font: Font
    private let foreground: Color
    private let icon: Icon
    private let message: Message
    private let background: Background

    public init(spacing: CGFloat? = nil, padding: CGFloat = Spacing.eight,
                font: Font = .caption, foreground: Color = .primary,
                @ViewBuilder icon: () -> Icon, @ViewBuilder message: () -> Message,
                @ViewBuilder background: () -> Background) {
        self.spacing = spacing; self.padding = padding; self.font = font; self.foreground = foreground
        self.icon = icon(); self.message = message(); self.background = background()
    }

    public var body: some View {
        HStack(spacing: spacing) { icon.accessibilityHidden(true); message }
            .font(font).foregroundColor(foreground).padding(padding)
            .frame(maxWidth: .infinity).background(background)
    }
}

/// Keeps the placeholder in layout when hidden, preserving the field's original size.
/// Bindings, focus, secure-entry state and validation remain in the supplied field.
public struct FieldPlaceholder<Field: View, Placeholder: View>: View {
    private let isVisible: Bool
    private let alignment: Alignment
    private let field: Field
    private let placeholder: Placeholder

    public init(isVisible: Bool, alignment: Alignment = .leading,
                @ViewBuilder field: () -> Field, @ViewBuilder placeholder: () -> Placeholder) {
        self.isVisible = isVisible; self.alignment = alignment
        self.field = field(); self.placeholder = placeholder()
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            placeholder.opacity(isVisible ? 1 : 0)
            field
        }
    }
}

extension View {
    public func fieldPlaceholder<Placeholder: View>(when isVisible: Bool,
        alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Placeholder) -> some View {
        FieldPlaceholder(isVisible: isVisible, alignment: alignment, field: { self }, placeholder: placeholder)
    }
}

/// Reusable artwork for native buttons. It owns no action, role, navigation or button style.
/// The image remains accessible; callers supply an appropriate control label and hit area.
public struct OutlinedIconLabel: View {
    private let systemImage: String
    private let metrics: IconMetrics
    private let color: Color
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat

    public init(systemImage: String, color: Color, metrics: IconMetrics = IconMetrics(),
                cornerRadius: CGFloat = CornerRadius.thirty, lineWidth: CGFloat = StrokeWidth.two) {
        self.systemImage = systemImage; self.color = color; self.metrics = metrics
        self.cornerRadius = cornerRadius; self.lineWidth = lineWidth
    }

    public var body: some View {
        Image(systemName: systemImage).renderingMode(.template).resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: metrics.size.width, height: metrics.size.height)
            .padding(.all, metrics.padding)
            .foregroundStyle(color)
            .background(RoundedRectangle(cornerRadius: cornerRadius).stroke(color, lineWidth: lineWidth))
    }
}

/// Native indeterminate progress centered vertically over a caller-provided backdrop.
/// Callers decide when it is present, its width, hit-testing policy and safe-area behavior.
public struct CenteredProgressOverlay<Label: View, Background: View>: View {
    private let width: CGFloat?
    private let label: Label
    private let background: Background

    public init(width: CGFloat? = nil, @ViewBuilder label: () -> Label,
                @ViewBuilder background: () -> Background) {
        self.width = width; self.label = label(); self.background = background()
    }

    public var body: some View {
        VStack {
            Spacer()
            ProgressView { label }.progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .frame(width: width)
        .background(background)
    }
}

extension CenteredProgressOverlay where Label == EmptyView {
    public init(
        width: KeyPath<DesignMetricTheme, CGFloat>? = nil,
        background: KeyPath<ColorTheme, Color>,
        opacity: KeyPath<OpacityTheme, Double>? = nil,
        metricTheme: DesignMetricTheme = .default,
        colorTheme: ColorTheme = .default,
        opacityTheme: OpacityTheme = .default
    ) where Background == Color {
        let base = colorTheme[keyPath: background]
        let resolved = opacity.map { base.opacity(opacityTheme[keyPath: $0]) } ?? base
        self.init(
            width: width.map { metricTheme[keyPath: $0] },
            label: { EmptyView() },
            background: { resolved }
        )
    }
}
