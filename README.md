# UIComponentsKit

A suite of composable, accessible SwiftUI surfaces, catalog items, and interactive button primitives. Built on top of `DesignTokensKit`.

![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B%20%7C%20macOS%2014.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange)
![Toolchain](https://img.shields.io/badge/Xcode-27.0-purple)
![CI](https://img.shields.io/badge/CI-Passing-brightgreen)
![SwiftLint](https://img.shields.io/badge/SwiftLint-0.65.1%20Strict-green)
![Dependencies](https://img.shields.io/badge/Dependencies-DesignTokensKit%201.2.0-blueviolet)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## Architecture

```mermaid
flowchart TD
    Consumer["Views & Screens (ShowBook / MyTV)"] --> UIComponentsKit["UIComponentsKit"]
    UIComponentsKit --> Surfaces["SurfaceCard & ContentTile"]
    UIComponentsKit --> Buttons["TokenButtonStyle (44pt Accessible)"]
    UIComponentsKit --> Catalog["CatalogTile & CatalogLayout (List / Grid)"]
    UIComponentsKit --> Primitives["Presentation Primitives (Banners, Placeholders, Overlays)"]
    UIComponentsKit --> Tokens["DesignTokensKit (1.2.0)"]
    Surfaces --> Tokens
    Buttons --> Tokens
    Catalog --> Tokens
```

`UIComponentsKit` provides production-ready UI components designed around pure composability:

1. **Decoupled Caller Ownership**:
   - The package contains **no app models, network requests, persistence, or localized string catalogs**.
   - Callers retain ownership of image loading, data bindings, action closures, and navigation.
2. **Accessible Interaction & Geometry**:
   - `TokenButtonStyle`: Implements native `ButtonStyle` with minimum 44pt touch targets adhering to Human Interface Guidelines.
   - `CatalogLayout`: Supports dynamic switching between `.list` and `.grid` layouts, with automatic fallback to list presentation under Dynamic Type accessibility sizes.
3. **Presentation Primitives**:
   - `StateMessage`: Empty, error, and informational state banners with iconography and action slots.
   - `IconMessageBanner`: Edge-to-edge message banner with semantic color styling.
   - `FieldPlaceholder`: Non-destructive placeholder layout overlay that prevents layout jumps.
   - `CenteredProgressOverlay`: Centered loading spinner backdrop.
4. **Strict Concurrency Compliance**:
   - Built with `-strict-concurrency=complete`. All component metrics and models conform to `Sendable`.

---

## Use Cases

- **Catalog & Feed Construction**: Display media items, books, or video cards with `CatalogTile`, switching smoothly between list rows and grid tiles.
- **Empty & Error State Views**: Provide standardized state messages (`StateMessage`) with actionable buttons for empty search results or network failures.
- **Form & Input Polish**: Enhance text fields with non-destructive floating placeholders (`FieldPlaceholder`) and standardized action buttons.
- **Custom Themed Cards**: Encapsulate elevated or bordered content containers with `SurfaceCard`.

---

## Catalog Layout Recipes & Reusable Control Governance (IOS-62, IOS-67)

### 1. Catalog Layout Recipes (IOS-62)
- `CatalogTileMetrics.compactGridRecipe(accessibility:)`: Relocated from primitive tokens to `UIComponentsKit` as a component preset recipe. Retains semantic dimensions (`120x120` standard, `160x170` accessibility) and corner radius tokens (`CornerRadius.twenty`).
- `CatalogLayout.resolved(isAccessibilitySize:)`: Automatically adapts grid presentations to list presentation under Dynamic Type accessibility environments.

### 2. Reusable Host Control Governance & Decisions (IOS-67)
- **SideActionIconView** (*Motivation Daily*): **Keep Local**. Strongly bound to `MotivationStrings`, quote viewer gesture handling, and photo export overlay lifecycle. Extraction into a shared component would add premature abstraction for a single-host vertical interaction.
- **BookCoverPreview & BookItem** (*ShowBook*): **Keep Local**. Domain-specific Core Data models and book metadata belong in the host application; generic container layout is provided by `CatalogTile` and `SurfaceCard`.
- **ChannelLogo & StreamRow** (*MyTV*): **Keep Local**. Encapsulates AVPlayer stream playback URLs, IPTV transport states, and aspect-ratio constraints.
- **CatalogLayoutMenu & AppearanceMenu**: **Shared in UIComponentsKit**. Uniformly adopted across all three host applications.
- **SelectionToggleButton & LoadingOverlayView**: **Shared in UIComponentsKit**. Reusable interactive selection and modal loading indicators.

---

## Practical Code Examples

### 1. CatalogTile with Dynamic List/Grid Layout

```swift
import SwiftUI
import DesignTokensKit
import UIComponentsKit

struct MediaCatalogView: View {
    @State private var layout: CatalogLayout = .grid
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack {
            HStack {
                Text("Library")
                    .font(.title2.bold())
                Spacer()
                CatalogLayoutMenu(selection: layout) { newLayout in
                    layout = newLayout
                } onGridUnavailable: {
                    print("Grid layout unavailable at this accessibility size")
                }
            }
            .padding()

            ScrollView {
                CatalogTile(
                    layout: layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize),
                    artwork: {
                        Image(systemName: "tv.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                    },
                    details: {
                        Text("Cosmos")
                            .font(.headline)
                        Text("Science & Nature")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    },
                    actions: {
                        Button(action: {}) {
                            Image(systemName: "heart")
                        }
                    }
                )
            }
        }
    }
}
```

### 2. StateMessage for Empty Search Results

```swift
import SwiftUI
import DesignTokensKit
import UIComponentsKit

struct EmptySearchView: View {
    var onReset: () -> Void

    var body: some View {
        StateMessage(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "We couldn't find any titles matching your query. Try searching for a different keyword.",
            actionTitle: "Clear Search",
            onAction: onReset
        )
        .padding()
    }
}
```

### 3. SurfaceCard with Custom Metrics

```swift
import SwiftUI
import DesignTokensKit
import UIComponentsKit

struct FeaturedCard: View {
    var body: some View {
        SurfaceCard(
            metrics: SurfaceMetrics(
                padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                cornerRadius: CornerRadius.sixteen,
                borderWidth: StrokeWidth.one
            ),
            colors: SemanticColors(
                surface: Color(.secondarySystemBackground),
                border: Color(.separator)
            )
        ) {
            VStack(alignment: .leading, spacing: Spacing.eight) {
                Text("Editor's Choice")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                Text("Building Scalable Swift Packages")
                    .font(.headline)
            }
        }
    }
}
```

### 4. Accessible Button Styling

```swift
import SwiftUI
import DesignTokensKit
import UIComponentsKit

struct ConfirmButton: View {
    var action: () -> Void

    var body: some View {
        Button("Confirm Order", action: action)
            .buttonStyle(TokenButtonStyle(
                metrics: ButtonMetrics(cornerRadius: CornerRadius.twenty),
                colors: SemanticColors(action: .blue, onAction: .white)
            ))
    }
}
```

---

## Release Version Controlling

`UIComponentsKit` adheres strictly to [Semantic Versioning (SemVer 2.0.0)](https://semver.org/spec/v2.0.0.html):

| Release Level | Criteria | Example Tag |
| :--- | :--- | :--- |
| **MAJOR** (`X.0.0`) | Breaking changes to component signatures, layout contracts | `v2.0.0` |
| **MINOR** (`1.X.0`) | New components, additional layout options, presentation primitives | `v1.2.0` |
| **PATCH** (`1.2.X`) | Bug fixes, rendering parity adjustments, styling fixes | `v1.2.1` |

- **Release Documentation**: Documented in [CHANGELOG.md](CHANGELOG.md).
- **Tag Validation**: Release tags follow `vX.Y.Z` and are validated using `bash Scripts/verify-release-version.sh`.
- **SPM Integration**:
  ```swift
  .package(url: "https://github.com/Anurag-Chourasia/UIComponentsKit.git", exact: "1.2.0")
  ```

---

## Quality & CI Verification

Every pull request and merge to `main` must pass all CI checks before merging:

1. **SwiftLint Gate**:
   - Pinned SwiftLint 0.65.1 enforcement (`.swiftlint.yml`).
   - Zero-warning strict mode (`--strict`).
   - Run locally: `bash Scripts/lint.sh`.
2. **Build, Test & Interaction Gate**:
   - Host target compilation and unit test execution with complete strict concurrency (`-strict-concurrency=complete`) and `-warnings-as-errors`.
   - iOS Simulator product verification via `xcodebuild`.
   - Native iOS UI interaction test suite (`Validation/run-interactions.sh`).

## Shared application controls

`AppearanceMenu` takes localized system/light/dark labels and an optional selection-feedback closure. Appearance state uses the existing `appAppearance` preference and `appAppearance()` applies it to the window hierarchy. Hosts retain branding and navigation.

`LoadingOverlayView(message:)`, `EmptyStateMessageView`, and `OfflineBannerView` provide shared state presentation. `SelectionToggleButton` accepts controlled selection state, localized action labels, and host-owned artwork/action closures; it does not own persistence, domain models, or haptic policy.

## Architecture guard tooling and ComponentIdentifier validation contract

`ComponentIdentifier` (`A11yID`) is a validated `RawRepresentable` value type with explicit ownership domains (`ComponentIdentifier.Namespace`: `.shared`, `.auth`, `.showBook`, `.myTV`, and `.motivationDaily`) rather than a closed enum. It does not conform to `ExpressibleByStringLiteral`: production views and shared UI components must reference registered static identifiers (`.developerOpenApp`, `.appearanceMenu`, `.authEmail`, `.contentMenuButton`) or typed parameterized builders (`.bookTile(_:)`, `.authProvider(_:)`). `ComponentIdentifier(rawValue:)` is failable and resolves only registered or valid dynamic identifiers; `ComponentIdentifier(validating:namespace:)` validates the lexical format (`[A-Za-z0-9]+([._-][A-Za-z0-9]+)*`) and prevents cross-namespace spoofing.

`Scripts/check_architecture.py` is the cross-workspace lexical scanner and coverage inventory for the approved IOS-55 and IOS-64 contracts. It is tooling, not a new runtime dependency. Run its regressions with `python3 -m unittest discover -s Scripts/tests -p test_architecture_guard.py -v`.

From the Projects workspace, run `python3 UIComponentsKit/Scripts/check_architecture.py --workspace-root . --output /tmp/architecture-report.json`. `--scope UIComponentsKit` explicitly selects a subset; without it every policy root is required. Missing coverage exits 2; findings exit 1. Existing findings are not a passing baseline and are not suppressed. Generated Swift and color asset catalogs are included.

The policy JSON and report state current limits. This scanner checks direct/ternary symbol arguments, direct accessibility literals, indirect `ComponentIdentifier`/`A11yID` string construction, unknown/unregistered `.accessibilityIdentifier(...)` members, invalid identifier formats, inline color constructors, asset ownership, and selected forbidden imports. It does not claim whole-program AST or cross-module runtime alias data-flow analysis, fixture-pixel exceptions, generator provenance, or production/test product linkage. SnapshotTestingKit is the local checkout inventory; active SnapshotTestKit linkage still needs inspection. Existing app token guards stay enabled. CI runs scanner regressions; migration-aware ecosystem enforcement remains tracked under IOS-56.

The canonical contract, decisions and changing architecture maps remain in the workspace `Docs/MASTER.md` and its linked Notion page. IOS-55 and IOS-64 approve the recorded revision; future architecture changes require a dated decision update and corresponding rule/test changes, not a claim that today's contract is immutable.
