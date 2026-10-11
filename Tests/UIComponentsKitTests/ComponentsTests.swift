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

}
