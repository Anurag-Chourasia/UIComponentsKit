# Changelog

## 1.1.0

- Add StateMessage, IconMessageBanner, FieldPlaceholder/fieldPlaceholder, OutlinedIconLabel and CenteredProgressOverlay from app compositions.
- Consume DesignTokensKit 1.1.0; existing 1.0.0 component APIs are unchanged.

## 1.0.0 — candidate

- Add generic configurable card, distinct visual/caption tile, and native button style.
- Consume exact DesignTokensKit 1.0.0; keep models, actions and strings caller-owned.
- Add rendered geometry and native accessibility tests plus strict CI.

- Match native clipping with one antialiased edge; regression tests compare exact rendered bytes for adaptive and inset-shadow surfaces.
