import SwiftUI
import XCTest
import DesignTokensKit
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

        let emptyState = EmptyStateMessageView(
            symbol: \.tray,
            title: "No Items",
            message: "Check back later"
        )
        XCTAssertNotNil(emptyState)
    }
}
