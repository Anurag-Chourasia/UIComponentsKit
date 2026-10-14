import SwiftUI
import UIComponentsKit
import DesignTokensKit

@main struct InteractionApp: App {
    @State private var count = 0
    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("catalog") {
                CatalogDemo().environment(\.dynamicTypeSize, CommandLine.arguments.contains("large-type") ? .accessibility5 : .large)
            } else if CommandLine.arguments.contains("presentation") {
                PresentationDemo()
            } else {
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
}

private struct PresentationDemo: View {
    @State private var count = 0
    @State private var text = ""

    var body: some View {
        VStack {
            Text("Count \(count)").accessibilityIdentifier("count")
            StateMessage {
                Image(systemName: "wifi.exclamationmark")
            } title: {
                Text("Unavailable")
            } detail: {
                Text("Caller-owned detail")
            } actions: {
                Button("Retry") { count += 1 }.accessibilityIdentifier("retry")
            }
            Button { count += 1 } label: {
                OutlinedIconLabel(systemImage: "chevron.left", color: .blue)
            }
            .accessibilityLabel("Go back")
            .accessibilityIdentifier("outlined")
            TextField("Email", text: $text)
                .fieldPlaceholder(when: text.isEmpty) { Text("Caller placeholder") }
                .accessibilityIdentifier("field")
            IconMessageBanner {
                Image(systemName: "wifi.slash")
            } message: {
                Text("Offline notice")
            } background: { Color.gray.opacity(0.1) }
            ProgressView("Reference loading").progressViewStyle(CircularProgressViewStyle())
            CenteredProgressOverlay(width: 220) { Text("Loading fixture") }
                background: { Color.gray.opacity(0.1) }
                .frame(height: 80)
        }.padding()
    }
}


private struct CatalogDemo: View {
    @State private var layout = CatalogLayout.list
    @State private var count = 0
    @State private var unavailable = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var body: some View {
        ScrollView {
            VStack {
                Text("Count \(count)").accessibilityIdentifier("count")
                Text(layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize).rawValue).accessibilityIdentifier("layout-value")
                CatalogLayoutMenu(selection: layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize),
                                  isAccessibilitySize: dynamicTypeSize.isAccessibilitySize,
                                  onSelect: { layout = $0 }, onGridUnavailable: { unavailable = true })
                    .accessibilityIdentifier("layout-menu")
                if unavailable { Text("List required").accessibilityIdentifier("unavailable") }
                CatalogTile(layout: layout.resolved(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize),
                            colors: SemanticColors(surface: DesignColor.groupedSecondary)) {
                    Image(systemName: "book").accessibilityHidden(true)
                } details: {
                    Button("Open item") { count += 10 }.accessibilityIdentifier("open-item")
                } accessory: {
                    Button("Favorite") { count += 1 }.accessibilityIdentifier("favorite-item")
                }
            }.padding()
        }
    }
}
