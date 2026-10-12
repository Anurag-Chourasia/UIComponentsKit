import SwiftUI
import XCTest
import UIComponentsKit
import DesignTokensKit

@MainActor final class PresentationParityTests: XCTestCase {
    private func pixels<V: View>(_ view: V) throws -> Data {
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        return try XCTUnwrap(image.dataProvider?.data) as Data
    }

    func testStateMessagePreservesEmptyAndActionLayouts() throws {
        for scheme in [ColorScheme.light, .dark] {
            for showAction in [false, true] {
                let original = VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark").font(.largeTitle).accessibilityHidden(true)
                    Text("Unavailable").font(.headline)
                    Text("A caller-owned message wrapping over multiple lines.")
                        .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center)
                    if showAction { Button("Retry", action: {}) }
                }.frame(width: 180)
                let migrated = StateMessage {
                    Image(systemName: "wifi.exclamationmark")
                } title: {
                    Text("Unavailable")
                } detail: {
                    Text("A caller-owned message wrapping over multiple lines.")
                } actions: {
                    if showAction { Button("Retry", action: {}) }
                }.frame(width: 180)
                XCTAssertEqual(try pixels(original.environment(\.colorScheme, scheme)),
                               try pixels(migrated.environment(\.colorScheme, scheme)))
            }
        }
        // Exercise the no-actions overload as well as conditional actions.
        let empty = StateMessage { Color.clear.frame(width: 10, height: 10) }
            title: { Color.red.frame(width: 20, height: 10) }
            detail: { Color.blue.frame(width: 20, height: 10) }
        let reference = VStack(spacing: 16) {
            Color.clear.frame(width: 10, height: 10)
            Color.red.frame(width: 20, height: 10)
            Color.blue.frame(width: 20, height: 10)
        }
        XCTAssertEqual(try pixels(empty), try pixels(reference))
    }

    func testBannerPreservesSystemSpacingAndWrapping() throws {
        let original = HStack {
            Image(systemName: "wifi.slash").accessibilityHidden(true)
            Text("Offline. Showing previously cached content.")
        }.font(.caption).foregroundColor(.white).padding(8)
            .frame(maxWidth: .infinity).background(Color.red)
        let migrated = IconMessageBanner(foreground: .white) {
            Image(systemName: "wifi.slash")
        } message: {
            Text("Offline. Showing previously cached content.")
        } background: { Color.red }
        XCTAssertEqual(try pixels(original.frame(width: 180)), try pixels(migrated.frame(width: 180)))
    }

    func testPlaceholderRetainsLayoutWhenHidden() throws {
        for isVisible in [true, false] {
            let field = Color.clear.frame(width: 80, height: 20)
            let placeholder = Text("A longer placeholder").font(.title2)
            let original = ZStack(alignment: .leading) {
                placeholder.opacity(isVisible ? 1 : 0)
                field
            }
            let migrated = field.fieldPlaceholder(when: isVisible) { placeholder }
            XCTAssertEqual(try pixels(original), try pixels(migrated))
        }
    }

    func testOutlinedLabelPreservesDefaultAndExplicitPadding() throws {
        for padding in [CGFloat?.none, CGFloat?(0), CGFloat?(12)] {
            let original = Image(systemName: "chevron.left").renderingMode(.template).resizable()
                .aspectRatio(contentMode: .fit).frame(width: 15, height: 15)
                .padding(.all, padding).foregroundStyle(Color.blue)
                .background(RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth: 2))
            let migrated = OutlinedIconLabel(systemImage: "chevron.left", color: .blue,
                                            metrics: IconMetrics(padding: padding))
            XCTAssertEqual(try pixels(original), try pixels(migrated))
        }
    }

    func testProgressOverlayPreservesLabelAndBackdropGeometry() throws {
        let original = VStack {
            Spacer()
            ProgressView("Loading.").progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }.frame(width: 220).background(Color.white.opacity(0.5))
        let migrated = CenteredProgressOverlay(width: 220) { Text("Loading.") }
            background: { Color.white.opacity(0.5) }
        // ImageRenderer compares the static label/background; native spinner behavior is UI-tested.
        XCTAssertEqual(try pixels(original.frame(height: 160)), try pixels(migrated.frame(height: 160)))
    }
}
