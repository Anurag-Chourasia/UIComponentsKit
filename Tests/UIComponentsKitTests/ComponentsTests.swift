import SwiftUI
import XCTest
import DesignTokensKit
import LocalizationKit
import UIComponentsKit

@MainActor
final class ComponentsTests: XCTestCase {
    func testButtonConsumesCallerGeometryAndTheme() {
        let metrics = ButtonMetrics(minimumWidth: 61, minimumHeight: 55, cornerRadius: 26.5)
        let colors = SemanticColors(action: .blue, onAction: .white)
        let style = TokenButtonStyle(metrics: metrics, colors: colors)
        XCTAssertEqual(style.metrics, metrics)
        XCTAssertEqual(style.colors.action, .blue)
        XCTAssertEqual(style.colors.onAction, .white)
    }

    func testCardPaddingChangesIntrinsicSizeWithoutFixedHeight() throws {
        let view = SurfaceCard(metrics: SurfaceMetrics(
            padding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))) {
            Color.red.frame(width: 50, height: 30)
        }
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        XCTAssertEqual(image.width, 74)
        XCTAssertEqual(image.height, 46)
    }

    func testTileHasDistinctVisualCaptionLayout() throws {
        let view = ContentTile(spacing: 12, metrics: SurfaceMetrics(padding: EdgeInsets())) {
            Color.red.frame(width: 50, height: 30)
        } caption: {
            Color.blue.frame(width: 70, height: 20)
        }
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        XCTAssertEqual(image.width, 70)
        XCTAssertEqual(image.height, 62)
    }

    func testLongLabelCanGrowBeyondMinimumHeight() throws {
        let view = Button {} label: {
            Text("A long action label that must wrap over several lines")
                .font(.largeTitle).fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(TokenButtonStyle(metrics: ButtonMetrics(minimumHeight: 44)))
        .frame(width: 160)
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        XCTAssertGreaterThan(image.height, 44)
    }

    func testComponentIdentifierNamespacesAndValidationContract() {
        let id: ComponentIdentifier = .developerSupport
        XCTAssertEqual(id.rawValue, "developer-support")
        XCTAssertEqual(id.description, "developer-support")
        XCTAssertEqual(id.namespace, .shared)

        let alias: A11yID = .screenTools
        XCTAssertEqual(alias.rawValue, "screen-tools")
        XCTAssertEqual(alias.namespace, .shared)

        let myTVStreamToggle: ComponentIdentifier = .hideUnavailableStreams
        XCTAssertEqual(myTVStreamToggle.namespace, .myTV)

        let motivationTabs: ComponentIdentifier = .contentCategoryTabs
        XCTAssertEqual(motivationTabs.namespace, .motivationDaily)

        let typedBookTile = ComponentIdentifier.bookTile(.grid)
        XCTAssertEqual(typedBookTile.rawValue, "book-tile-grid")
        XCTAssertEqual(typedBookTile.namespace, .showBook)

        let dynamicBook = ComponentIdentifier.bookTile("grid")
        XCTAssertEqual(dynamicBook, typedBookTile)

        let sanitizedBook = ComponentIdentifier.bookTile("invalid layout!")
        XCTAssertEqual(sanitizedBook.rawValue, "book-tile-list")

        let typedAuthProvider = ComponentIdentifier.authProvider(.google)
        XCTAssertEqual(typedAuthProvider.rawValue, "auth.provider.google")
        XCTAssertEqual(typedAuthProvider.namespace, .auth)

        let dynamicAuth = ComponentIdentifier.authProvider("google")
        XCTAssertEqual(dynamicAuth, typedAuthProvider)

        let sanitizedAuth = ComponentIdentifier.authProvider("bad provider!")
        XCTAssertEqual(sanitizedAuth.rawValue, "auth.provider.apple")

        XCTAssertEqual(ComponentIdentifier.authEmail.rawValue, "auth.email")
        XCTAssertEqual(ComponentIdentifier.authConfirmPassword.rawValue, "auth.confirmPassword")
        XCTAssertEqual(ComponentIdentifier.authForgotPassword.rawValue, "auth.forgotPassword")
        XCTAssertEqual(ComponentIdentifier.authSwitchMode.rawValue, "auth.switchMode")
        XCTAssertEqual(ComponentIdentifier.authAccountEmail.rawValue, "auth.accountEmail")
        XCTAssertEqual(ComponentIdentifier.authAccountResetPassword.rawValue, "auth.accountResetPassword")
        XCTAssertEqual(ComponentIdentifier.authSignOut.rawValue, "auth.signOut")
        XCTAssertEqual(ComponentIdentifier.authDeleteAccount.rawValue, "auth.deleteAccount")

        // Registered lookup succeeds; arbitrary unvalidated strings fail closed.
        XCTAssertEqual(ComponentIdentifier(rawValue: "developer-open-app"), .developerOpenApp)
        XCTAssertEqual(ComponentIdentifier(rawValue: "book-tile-list")?.namespace, .showBook)
        XCTAssertEqual(ComponentIdentifier(rawValue: "auth.provider.github")?.namespace, .auth)
        XCTAssertNil(ComponentIdentifier(rawValue: "arbitrary-unregistered-id"))
        XCTAssertNil(ComponentIdentifier(rawValue: ""))
        XCTAssertNil(ComponentIdentifier(rawValue: "invalid space"))
        XCTAssertNil(ComponentIdentifier(rawValue: ".leading-dot"))
        XCTAssertNil(ComponentIdentifier(rawValue: "trailing-hyphen-"))
        XCTAssertNil(ComponentIdentifier(rawValue: "double..dot"))

        // Explicit namespace validation enforces format and prevents namespace spoofing.
        let validatedHostID = ComponentIdentifier(validating: "custom.host-control", namespace: .showBook)
        XCTAssertEqual(validatedHostID?.rawValue, "custom.host-control")
        XCTAssertEqual(validatedHostID?.namespace, .showBook)
        XCTAssertNil(ComponentIdentifier(validating: "developer-open-app", namespace: .showBook))
        XCTAssertNil(ComponentIdentifier(validating: "invalid space", namespace: .shared))

        XCTAssertTrue(ComponentIdentifier.registeredIdentifiers.allSatisfy {
            ComponentIdentifier.isValidFormat($0.rawValue) && ComponentIdentifier.isRegistered($0.rawValue)
        })

        let view = Text("Hello").accessibilityIdentifier(.developerSupport)
        XCTAssertNotNil(view)
    }

    func testAppAppearanceAndStandardComponents() {
        XCTAssertEqual(AppAppearance.allCases.count, 3)
        XCTAssertEqual(AppAppearance.system.rawValue, "system")
        XCTAssertEqual(AppAppearance.light.rawValue, "light")
        XCTAssertEqual(AppAppearance.dark.rawValue, "dark")
        XCTAssertNil(AppAppearance.system.colorScheme)
        XCTAssertEqual(AppAppearance.light.colorScheme, .light)
        XCTAssertEqual(AppAppearance.dark.colorScheme, .dark)

        let banner = OfflineBannerView(message: "Offline Mode")
        XCTAssertNotNil(banner)

        let customBanner = OfflineBannerView(message: "Offline Warning", isWarning: false, backgroundColor: \.orange)
        XCTAssertNotNil(customBanner)

        let emptyState = EmptyStateMessageView(
            symbol: \.tray,
            title: "No Items",
            message: "Check back later"
        )
        XCTAssertNotNil(emptyState)
    }

    func testKeyPathModifiersAcrossComponents() throws {
        // IconMessageBanner with KeyPaths
        let banner = IconMessageBanner(
            spacing: \.eight,
            padding: \.sixteen,
            font: \.footnote,
            foreground: \.white,
            background: \.red,
            icon: { Image(\.wifiSlash) },
            message: { Text("Connection offline") }
        )
        let bannerImage = try XCTUnwrap(ImageRenderer(content: banner.frame(width: 200)).cgImage)
        XCTAssertGreaterThan(bannerImage.width, 0)

        // OutlinedIconLabel with KeyPaths
        let outlinedSymbol = OutlinedIconLabel(
            symbol: \.chevronLeft,
            color: \.brandPrimary,
            cornerRadius: \.r12,
            lineWidth: \.two
        )
        let outlinedImage = try XCTUnwrap(ImageRenderer(content: outlinedSymbol).cgImage)
        XCTAssertGreaterThan(outlinedImage.width, 0)

        let outlinedNamed = OutlinedIconLabel(
            systemImage: "star.fill",
            color: \.yellow,
            cornerRadius: \.thirty,
            lineWidth: \.one
        )
        let namedImage = try XCTUnwrap(ImageRenderer(content: outlinedNamed).cgImage)
        XCTAssertGreaterThan(namedImage.width, 0)

        // CenteredProgressOverlay with KeyPaths and label
        let overlay = CenteredProgressOverlay(
            width: \.p96,
            background: \.black,
            opacity: \.p0_35
        ) {
            Text("Syncing")
        }
        let overlayImage = try XCTUnwrap(ImageRenderer(content: overlay.frame(height: 100)).cgImage)
        XCTAssertGreaterThan(overlayImage.height, 0)

        // StateMessage with KeyPaths for typography and spacing
        let stateMsg = StateMessage(
            spacing: \.twenty,
            detailColor: \.secondary,
            iconFont: \.title,
            titleFont: \.headline,
            detailFont: \.caption,
            icon: { Image(\.exclamationmarkTriangle) },
            title: { Text("Warning") },
            detail: { Text("Check your configuration") },
            actions: { Button("Retry") {} }
        )
        let stateMsgImage = try XCTUnwrap(ImageRenderer(content: stateMsg.frame(width: 200)).cgImage)
        XCTAssertGreaterThan(stateMsgImage.height, 0)

        // StateMessage with no actions
        let stateMsgNoAction = StateMessage(
            spacing: \.twelve,
            detailColor: \.secondary,
            iconFont: \.headline,
            titleFont: \.subheadline,
            detailFont: \.footnote,
            icon: { Image(\.infoCircle) },
            title: { Text("Information") },
            detail: { Text("Everything is up to date") }
        )
        let noActionImage = try XCTUnwrap(ImageRenderer(content: stateMsgNoAction.frame(width: 200)).cgImage)
        XCTAssertGreaterThan(noActionImage.height, 0)

        // SurfaceCard with KeyPaths
        let card = SurfaceCard(
            surfaceColor: \.surface,
            borderColor: \.border,
            cornerRadius: \.r12,
            borderWidth: \.one,
            padding: \.sixteen
        ) {
            Text("Card content")
        }
        let cardImage = try XCTUnwrap(ImageRenderer(content: card).cgImage)
        XCTAssertGreaterThan(cardImage.width, 0)

        // ContentTile with KeyPaths
        let tile = ContentTile(
            spacing: \.eight,
            metrics: SurfaceMetrics(cornerRadius: 12)
        ) {
            Image(\.tv)
        } caption: {
            Text("Living Room")
        }
        let tileImage = try XCTUnwrap(ImageRenderer(content: tile).cgImage)
        XCTAssertGreaterThan(tileImage.width, 0)

        // TokenButtonStyle with KeyPaths
        let button = Button("Confirm") {}
            .buttonStyle(TokenButtonStyle(actionColor: \.brandPrimary, onActionColor: \.white, cornerRadius: \.r12))
        let buttonImage = try XCTUnwrap(ImageRenderer(content: button).cgImage)
        XCTAssertGreaterThan(buttonImage.width, 0)

        // LoadingOverlayView
        let loading = LoadingOverlayView(message: "Please wait")
        let loadingImage = try XCTUnwrap(ImageRenderer(content: loading.frame(width: 150, height: 150)).cgImage)
        XCTAssertGreaterThan(loadingImage.width, 0)
    }

    func testLocalizedKeyPathInitializersAndPlaybackSurfaceView() throws {
        // Localized OfflineBannerView
        let offlineBanner = OfflineBannerView(messageKeyPath: \.offlineMessage)
        let bannerImage = try XCTUnwrap(ImageRenderer(content: offlineBanner.frame(width: 250)).cgImage)
        XCTAssertGreaterThan(bannerImage.width, 0)

        // Localized EmptyStateMessageView
        let emptyState = EmptyStateMessageView(
            symbol: \.tray,
            titleKeyPath: \.emptyTitle,
            messageKeyPath: \.emptyMessage
        )
        let emptyStateImage = try XCTUnwrap(ImageRenderer(content: emptyState.frame(width: 200)).cgImage)
        XCTAssertGreaterThan(emptyStateImage.height, 0)

        // Localized LoadingOverlayView
        let localizedLoading = LoadingOverlayView(messageKeyPath: \.loading)
        let loadingImage = try XCTUnwrap(ImageRenderer(content: localizedLoading.frame(width: 150, height: 150)).cgImage)
        XCTAssertGreaterThan(loadingImage.width, 0)

        // Localized AppearanceMenu
        let menu = AppearanceMenu(
            titleKeyPath: \.appearanceTitle,
            systemTitleKeyPath: \.appearanceSystem,
            lightTitleKeyPath: \.appearanceLight,
            darkTitleKeyPath: \.appearanceDark
        )
        XCTAssertNotNil(menu)

        // Localized CatalogLayoutMenu
        let layoutMenu = CatalogLayoutMenu(
            selection: .list,
            titleKeyPath: \.layoutTitle,
            onSelect: { _ in }
        )
        XCTAssertNotNil(layoutMenu)

        // Localized PlaybackSurfaceView
        var playPauseToggled = false
        var muteToggled = false
        var replayed = false
        var stopped = false

        let playback = PlaybackSurfaceView(
            isPlaying: false,
            isLive: true,
            isMuted: false,
            onPlayPause: { playPauseToggled = true },
            onMuteToggle: { muteToggled = true },
            onReplay: { replayed = true },
            onStop: { stopped = true }
        ) {
            Color.blue.frame(width: 320, height: 180)
        }
        let playbackImage = try XCTUnwrap(ImageRenderer(content: playback.frame(width: 320, height: 180)).cgImage)
        XCTAssertGreaterThan(playbackImage.width, 0)
        XCTAssertFalse(playPauseToggled)
        XCTAssertFalse(muteToggled)
        XCTAssertFalse(replayed)
        XCTAssertFalse(stopped)

        // Playing & Muted configuration
        let playingPlayback = PlaybackSurfaceView(
            isPlaying: true,
            isLive: false,
            isMuted: true,
            onPlayPause: {},
            onMuteToggle: {}
        )
        let playingImage = try XCTUnwrap(ImageRenderer(content: playingPlayback.frame(width: 320, height: 180)).cgImage)
        XCTAssertGreaterThan(playingImage.height, 0)

        // Verify localization keys are populated in CommonStrings
        let strings = CommonStrings.shared
        XCTAssertFalse(strings.playbackPlay.isEmpty)
        XCTAssertFalse(strings.playbackPause.isEmpty)
        XCTAssertFalse(strings.playbackLive.isEmpty)
        XCTAssertFalse(strings.playbackMute.isEmpty)
        XCTAssertFalse(strings.playbackUnmute.isEmpty)
        XCTAssertFalse(strings.playbackReplay.isEmpty)
        XCTAssertFalse(strings.playbackStop.isEmpty)
    }

    func testRemoteImageAndImageDataLoadingProtocol() async throws {
        // 1. AnyImageDataLoading and load alias
        let sampleURL = try XCTUnwrap(URL(string: "https://example.com/test.png"))
        let samplePayload = Data([0xDE, 0xAD, 0xBE, 0xEF])
        let loader = AnyImageDataLoading { url in
            XCTAssertEqual(url, sampleURL)
            return samplePayload
        }

        let loadedData = try await loader.loadImageData(from: sampleURL)
        XCTAssertEqual(loadedData, samplePayload)
        let loadedViaAlias = try await loader.load(from: sampleURL)
        XCTAssertEqual(loadedViaAlias, samplePayload)

        // 2. RemoteImagePhase accessors
        let emptyPhase = RemoteImagePhase.empty
        XCTAssertNil(emptyPhase.image)
        XCTAssertNil(emptyPhase.error)

        let loadingPhase = RemoteImagePhase.loading
        XCTAssertNil(loadingPhase.image)
        XCTAssertNil(loadingPhase.error)

        let sampleError = URLError(.badURL)
        let failurePhase = RemoteImagePhase.failure(sampleError)
        XCTAssertNil(failurePhase.image)
        XCTAssertNotNil(failurePhase.error)

        let sampleImage = Image(systemName: "photo")
        let successPhase = RemoteImagePhase.success(sampleImage)
        XCTAssertNotNil(successPhase.image)
        XCTAssertNil(successPhase.error)

        // 3. RemoteImage with various initializers
        let defaultRemote = RemoteImage(url: sampleURL, loader: loader)
        XCTAssertNotNil(defaultRemote)

        let withCustomPlaceholder = RemoteImage(url: sampleURL, loader: loader) {
            Text(verbatim: "Loading...")
        }
        XCTAssertNotNil(withCustomPlaceholder)

        let withCustomContent = RemoteImage(url: sampleURL, loader: loader) { image in
            image.resizable()
        } placeholder: {
            Text(verbatim: "Wait...")
        }
        XCTAssertNotNil(withCustomContent)

        let withCustomContentOnly = RemoteImage(url: sampleURL, loader: loader) { image in
            image.resizable().frame(width: 40, height: 40)
        }
        XCTAssertNotNil(withCustomContentOnly)

        // 4. RemoteImagePhaseView
        let phaseView = RemoteImagePhaseView(url: sampleURL, loader: loader) { phase in
            switch phase {
            case .empty, .loading:
                Text(verbatim: "Loading")
            case .success(let image):
                image
            case .failure:
                Text(verbatim: "Error")
            }
        }
        XCTAssertNotNil(phaseView)

        // 5. Environment loader injection
        let viewWithEnv = RemoteImage(url: sampleURL)
            .imageDataLoader(loader)
        XCTAssertNotNil(viewWithEnv)

        // 6. Test rendering with real platform image data
        let colorView = Color.blue.frame(width: 10, height: 10)
        let renderer = ImageRenderer(content: colorView)
        #if canImport(UIKit)
        let realData = renderer.uiImage?.pngData()
        #elseif canImport(AppKit)
        let realData = renderer.nsImage?.tiffRepresentation
        #else
        let realData: Data? = nil
        #endif

        if let realData {
            let realLoader = AnyImageDataLoading { _ in realData }
            let renderedRemote = RemoteImage(url: sampleURL, loader: realLoader) { img in
                img.frame(width: 10, height: 10)
            } placeholder: {
                Color.clear.frame(width: 10, height: 10)
            }
            let cgImage = try XCTUnwrap(ImageRenderer(content: renderedRemote.frame(width: 10, height: 10)).cgImage)
            XCTAssertGreaterThan(cgImage.width, 0)
        }

        // 7. DefaultImageDataLoading instance
        let defaultLoader = DefaultImageDataLoading()
        XCTAssertNotNil(defaultLoader)
    }
}
