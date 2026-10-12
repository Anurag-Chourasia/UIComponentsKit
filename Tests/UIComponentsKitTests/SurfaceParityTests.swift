import XCTest
import SwiftUI
import UIComponentsKit
import DesignTokensKit

@MainActor final class SurfaceParityTests: XCTestCase {
    func pixels<V: View>(_ view: V) throws -> Data {
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        let data = try XCTUnwrap(image.dataProvider?.data) as Data
        return data
    }
    func testClippedAdaptiveGridCompositionMatchesInBothAppearances() throws {
        for scheme in [ColorScheme.light, .dark] {
            let content = ZStack(alignment: .topTrailing) {
                Color.blue.frame(width: 110, height: 110)
                Text("♥").foregroundStyle(.red)
            }.frame(width: 120).frame(minHeight: 120)
            let old = content.background(Color.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            let migrated = SurfaceCard(metrics: SurfaceMetrics(padding: EdgeInsets(), cornerRadius: 20),
                colors: SemanticColors(surface: .primary.opacity(0.1)), clipsContent: true) { content }
            XCTAssertEqual(try pixels(old.environment(\.colorScheme, scheme)),
                           try pixels(migrated.environment(\.colorScheme, scheme)))
        }
    }
    func testInsetShadowCardMatchesOriginalComposition() throws {
        let content = HStack(spacing: 0) {
            Color.blue.frame(width: 60, height: 100)
            Text("Caller content").frame(width: 140)
        }
        let old = content.padding(.horizontal, 23).padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 0).padding(.horizontal, 13))
        let migrated = SurfaceCard(
            metrics: SurfaceMetrics(padding: EdgeInsets(top: 16, leading: 23, bottom: 16, trailing: 23), cornerRadius: 15),
            colors: SemanticColors(surface: .white), cornerStyle: .continuous,
            backgroundInsets: EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13),
            shadow: SurfaceShadow(color: .black.opacity(0.4), radius: 3)) { content }
        XCTAssertEqual(try pixels(old), try pixels(migrated))
    }
}
