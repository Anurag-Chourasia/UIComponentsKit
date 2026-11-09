import SwiftUI
import DesignTokensKit
import LocalizationKit

#Preview("SurfaceCard - Light") {
    SurfaceCard {
        Text(verbatim: "Surface Card Content")
            .padding(\.medium)
    }
    .preferredColorScheme(.light)
}

#Preview("SurfaceCard - Dark") {
    SurfaceCard {
        Text(verbatim: "Surface Card Content")
            .padding(\.medium)
    }
    .preferredColorScheme(.dark)
}

#Preview("SurfaceCard - Dynamic Type") {
    SurfaceCard {
        Text(verbatim: "Surface Card Content")
            .padding(\.medium)
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("ContentTile - Light & Dark") {
    VStack(spacing: \.s16) {
        ContentTile {
            Color.blue.frame(width: 80, height: 80)
        } caption: {
            Text(verbatim: "Tile Caption")
        }
    }
    .padding(\.medium)
}

#Preview("CatalogTile - Grid & List") {
    VStack(spacing: \.s16) {
        CatalogTile(layout: .grid) {
            Color.purple.frame(height: 120)
        } details: {
            Text(verbatim: "Grid Item Details")
        } accessory: {
            Image(\.starFill)
        }

        CatalogTile(layout: .list) {
            Color.purple.frame(width: 60, height: 60)
        } details: {
            Text(verbatim: "List Item Details")
        } accessory: {
            Image(\.chevronRight)
        }
    }
    .padding(\.medium)
}

#Preview("PlaybackSurfaceView - Previews") {
    PlaybackSurfaceView(
        isPlaying: false,
        isLive: true,
        isMuted: false,
        onPlayPause: {},
        onMuteToggle: {},
        onReplay: {},
        onStop: {}
    ) {
        Color.black.frame(height: 200)
    }
}

#Preview("LoadingOverlayView - Previews") {
    LoadingOverlayView()
}

#Preview("StateMessage - Previews") {
    StateMessage {
        Image(\.wifiExclamationmark)
    } title: {
        Text(verbatim: "Connection Lost")
    } detail: {
        Text(verbatim: "Please check your network settings.")
    } actions: {
        Button(action: {}) {
            Text(verbatim: "Retry")
        }
    }
}

#Preview("IconMessageBanner - Previews") {
    IconMessageBanner(foreground: .white) {
        Image(\.wifiSlash)
    } message: {
        Text(verbatim: "Offline Mode Active")
    } background: {
        Color.orange
    }
}

#Preview("OutlinedIconLabel - Previews") {
    OutlinedIconLabel(symbol: \.chevronLeft, color: \.blue)
}

#Preview("CenteredProgressOverlay - Previews") {
    CenteredProgressOverlay(width: 200) {
        Text(verbatim: "Processing...")
    } background: {
        Color.black.opacity(0.3)
    }
}

#Preview("AppearanceMenu - Previews") {
    AppearanceMenu(
        title: "Appearance",
        systemTitle: "System",
        lightTitle: "Light",
        darkTitle: "Dark"
    )
}

#Preview("SelectionToggleButton - Previews") {
    SelectionToggleButton(
        isSelected: true,
        selectedLabel: "Active",
        unselectedLabel: "Inactive",
        action: {}
    ) {
        Image(\.checkmark)
    }
}

#Preview("RemoteImage - Previews") {
    RemoteImage(
        url: URL(string: "https://example.com/image.png"),
        loader: AnyImageDataLoading { _ in Data() }
    ) {
        Text(verbatim: "Loading preview...")
    }
}
