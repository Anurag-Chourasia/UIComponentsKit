import SwiftUI
import DesignTokensKit

public enum CatalogLayout: String, CaseIterable, Identifiable, Sendable {
    case list, grid
    public var id: String { rawValue }
    public var symbolKeyPath: KeyPath<SymbolTheme, AppSymbol> {
        switch self {
        case .list: return \.listBullet
        case .grid: return \.squareGrid2x2
        }
    }
    public var symbol: AppSymbol {
        SymbolTheme.default[keyPath: symbolKeyPath]
    }
    public var icon: String {
        symbol.systemName
    }
    public func resolved(isAccessibilitySize: Bool) -> Self { isAccessibilitySize ? .list : self }
}

/// Shared list/grid composition. Callers retain navigation, image loading, content,
/// and independent native buttons. No enclosing button or combined accessibility element.
public struct CatalogTile<Artwork: View, Details: View, Accessory: View>: View {
    private let layout: CatalogLayout
    private let metrics: CatalogTileMetrics
    private let colors: SemanticColors
    private let artwork: Artwork
    private let details: Details
    private let accessory: Accessory

    public init(layout: CatalogLayout, metrics: CatalogTileMetrics = .standard,
                colors: SemanticColors = SemanticColors(),
                @ViewBuilder artwork: () -> Artwork,
                @ViewBuilder details: () -> Details,
                @ViewBuilder accessory: () -> Accessory) {
        self.layout = layout; self.metrics = metrics; self.colors = colors
        self.artwork = artwork(); self.details = details(); self.accessory = accessory()
    }

    public var body: some View {
        SurfaceCard(metrics: metrics.surface, colors: colors, clipsContent: layout == .grid) {
            if layout == .list {
                HStack(spacing: metrics.spacing) {
                    artwork
                    details
                    Spacer(minLength: 0)
                    accessory
                }
            } else {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: \.zero) {
                        artwork.padding(.vertical, metrics.artworkPadding)
                        Spacer(minLength: 0)
                        details.padding(.bottom, metrics.detailPadding)
                        Spacer(minLength: 0)
                    }
                    .frame(width: metrics.contentWidth)
                    .frame(minHeight: metrics.contentMinHeight)
                    accessory
                }
                .frame(width: metrics.width)
                .frame(minHeight: metrics.minimumHeight)
                .frame(maxWidth: metrics.width == nil ? .infinity : nil)
            }
        }
    }
}

public struct CatalogLayoutMenu: View {
    private let selection: CatalogLayout
    private let isAccessibilitySize: Bool
    private let title: String
    private let titleForLayout: (CatalogLayout) -> String
    private let onSelect: (CatalogLayout) -> Void
    private let onGridUnavailable: () -> Void

    public init(selection: CatalogLayout, isAccessibilitySize: Bool = false,
                title: String = "common.layout.title",
                titleForLayout: @escaping (CatalogLayout) -> String = { "common.layout.\($0.rawValue)" },
                onSelect: @escaping (CatalogLayout) -> Void, onGridUnavailable: @escaping () -> Void = {}) {
        self.selection = selection; self.isAccessibilitySize = isAccessibilitySize
        self.title = title; self.titleForLayout = titleForLayout
        self.onSelect = onSelect; self.onGridUnavailable = onGridUnavailable
    }

    public init(selection: CatalogLayout, isAccessibilitySize: Bool = false,
                resolving resolve: @escaping (String) -> String,
                onSelect: @escaping (CatalogLayout) -> Void, onGridUnavailable: @escaping () -> Void = {}) {
        self.init(
            selection: selection,
            isAccessibilitySize: isAccessibilitySize,
            title: resolve("common.layout.title"),
            titleForLayout: { resolve("common.layout.\($0.rawValue)") },
            onSelect: onSelect,
            onGridUnavailable: onGridUnavailable
        )
    }

    public var body: some View {
        Menu {
            ForEach(CatalogLayout.allCases) { option in
                Button {
                    if option == .grid && isAccessibilitySize {
                        onGridUnavailable()
                    } else {
                        onSelect(option)
                    }
                } label: {
                    Label(
                        titleForLayout(option),
                        systemImage: selection == option ? \.checkmark : option.symbolKeyPath
                    )
                }
            }
        } label: {
            Label(title, systemImage: selection.symbolKeyPath)
        }
        .accessibilityValue(titleForLayout(selection))
    }
}

public extension CatalogTileMetrics {
    /// Component preset recipe for compact catalog media grids with accessibility support.
    static func compactGridRecipe(accessibility: Bool) -> Self {
        compactGrid(accessibility: accessibility)
    }
}
