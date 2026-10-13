# UIComponentsKit

Composable SwiftUI surfaces and button styling. Depends only on the exact DesignTokensKit 1.1.0 release. No app models, localization keys, networking, persistence or global theme state.

```swift
.package(url: "https://github.com/Anurag-Chourasia/UIComponentsKit.git", exact: "1.1.0")
// Declare UIComponentsKit, plus DesignTokensKit if directly using its public types.
```

## Components

- `SurfaceCard`: caller content, per-surface metrics/colors, circular or continuous corners, optional clipping, border, shadow and background insets. It does not group accessibility children or add tap gestures. Background decoration ignores hit testing and accessibility.
- `ContentTile`: a vertical layout with separate visual and caption builders, alignment and spacing. It uses SurfaceCard and can contain app-owned buttons or be a Button label; do not nest interactive controls inside another Button.
- `TokenButtonStyle`: apply to native Button. Caller owns action, role, label, disabled state and focus. Configurable token colors/geometry; default minimum dimensions are 44 points. Long labels can grow. No animation or motion is introduced.
- `SurfaceShadow`: optional app-owned decoration. No shared universal palette or shadow policy.

```swift
import SwiftUI
import DesignTokensKit
import UIComponentsKit

Button("Continue", action: {})
    .buttonStyle(TokenButtonStyle(
        metrics: ButtonMetrics(cornerRadius: 26.5),
        colors: SemanticColors(action: .blue, onAction: .white)))

SurfaceCard(metrics: SurfaceMetrics(cornerRadius: 20),
            colors: SemanticColors(surface: .gray.opacity(0.1))) {
    Text("Caller-owned content")
}
```

Keep native app controls when a shared style cannot preserve their existing behavior. Foreground text inside cards stays caller-owned. Supply appropriate accessibility labels, values and hints at the app; hide decorative images explicitly. Choose contrasting colors. There is no forced Dynamic Type limit or fixed text height.

## Validation and contribution

Declared iOS 16.6 / macOS 14. Baseline Xcode 27.0 (27A266a), Swift 6.4. Older toolchains and minimum-OS runtime unverified. Tests exercise token configuration, rendered geometry, long labels and native iOS UI-test taps, disabled state, accessible labels, minimum touch dimensions and nested card interactions. These do not constitute a manual VoiceOver audit or proof of visual parity in every app screen.

Owner: Anurag Chourasia. Add shared APIs only for meaningful consumers with public documentation, behavior tests and explicit compatibility intent. Preserve app appearance and localization ownership. Breaking behavior requires a major version; never move published tags.

MIT — Copyright (c) 2026 Anurag Chourasia.

## Presentation primitives (1.1.0)

- `StateMessage`: decorative icon, semantic title/detail typography and optional action slots. The caller keeps strings, outer padding, expansion and accessibility grouping.
- `IconMessageBanner`: full-width icon/message/background composition with optional system spacing, configurable font/color/padding. No reachability or message state.
- `FieldPlaceholder` / `.fieldPlaceholder(when:)`: placeholder behind arbitrary field content; opacity preserves layout while hidden. Bindings, secure-entry toggles, focus, debounce and validation stay local.
- `OutlinedIconLabel`: resizable symbol, optional system padding and configurable rounded outline. Use inside a native Button or NavigationLink, with caller-owned action, role, style, accessibility label and appropriate touch area.
- `CenteredProgressOverlay`: native indeterminate progress between flexible spacers over a caller backdrop. Width, presentation condition, blocking behavior and safe areas stay caller-owned.

These APIs extract existing app compositions without copying view models. They do not repair pre-existing app accessibility labels or fixed field heights. New screens should use meaningful field labels and growing text geometry; consumers preserve their existing contracts during migration.
