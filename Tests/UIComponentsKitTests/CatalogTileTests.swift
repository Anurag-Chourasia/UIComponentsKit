import XCTest
import SwiftUI
import UIComponentsKit
import DesignTokensKit

@MainActor final class CatalogTileTests: XCTestCase {
    private func pixels<V: View>(_ view: V) throws -> Data {
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        return try XCTUnwrap(image.dataProvider?.data) as Data
    }
    func testAccessibilityResolutionDoesNotDestroySavedPreference() {
        let saved = CatalogLayout.grid
        XCTAssertEqual(saved.resolved(isAccessibilitySize: true), .list)
        XCTAssertEqual(saved.resolved(isAccessibilitySize: false), .grid)
        XCTAssertEqual(CatalogLayout(rawValue: "list"), .list)
    }
    func testGridPreservesOriginalComposition() throws {
        for accessible in [false, true] {
            let metrics = CatalogTileMetrics.compactGrid(accessibility: accessible)
            let artwork = Color.blue.frame(width: accessible ? 120 : 90, height: accessible ? 80 : 64)
            let title = Text("Example channel").font(.headline).lineLimit(2).multilineTextAlignment(.center)
            let accessory = Text("♥").foregroundStyle(.red)
            let old = SurfaceCard(metrics: metrics.surface, colors: SemanticColors(surface: .gray), clipsContent: true) {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 0) {
                        artwork.padding(.vertical, 10)
                        Spacer(minLength: 0)
                        title.padding(.bottom, 10)
                        Spacer(minLength: 0)
                    }.frame(width: accessible ? 150 : 110).frame(minHeight: accessible ? 150 : 110)
                    accessory
                }.frame(width: accessible ? 160 : 120).frame(minHeight: accessible ? 170 : 120)
            }
            let shared = CatalogTile(layout: .grid, metrics: metrics, colors: SemanticColors(surface: .gray)) {
                artwork
            } details: { title } accessory: { accessory }
            for scheme in [ColorScheme.light, .dark] {
                XCTAssertEqual(try pixels(old.environment(\.colorScheme, scheme)), try pixels(shared.environment(\.colorScheme, scheme)))
            }
        }
    }
    func testListPreservesOriginalComposition() throws {
        let artwork = Color.blue.frame(width: 40, height: 40)
        let detail = Text("Example channel").font(.headline).padding(.horizontal, 8)
        let accessory = Text("♥")
        let old = HStack(spacing: 12) { artwork; detail; Spacer(minLength: 0); accessory }.frame(width: 320)
        let shared = CatalogTile(layout: .list, metrics: .plainRow) { artwork } details: { detail } accessory: { accessory }.frame(width: 320)
        XCTAssertEqual(try pixels(old), try pixels(shared))
    }
}
