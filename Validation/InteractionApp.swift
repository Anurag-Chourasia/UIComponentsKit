import SwiftUI
import UIComponentsKit
import DesignTokensKit

@main struct InteractionApp: App {
    @State private var count = 0
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Count \(count)").accessibilityIdentifier("count")
                Button("Increment") { count += 1 }
                    .buttonStyle(TokenButtonStyle(colors: SemanticColors(action: .blue, onAction: .white)))
                    .accessibilityIdentifier("increment")
                Button("Disabled") { count += 100 }
                    .buttonStyle(TokenButtonStyle())
                    .disabled(true)
                    .accessibilityIdentifier("disabled")
                SurfaceCard(metrics: SurfaceMetrics(cornerRadius: 20)) {
                    Button("Inside card") { count += 1 }
                        .accessibilityIdentifier("inside")
                }
                ContentTile {
                    Image(systemName: "book").accessibilityHidden(true)
                } caption: {
                    Text("A caller-owned caption").accessibilityIdentifier("caption")
                }
            }
        }
    }
}
