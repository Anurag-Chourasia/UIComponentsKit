import SwiftUI
import UIComponentsKit
import DesignTokensKit

@main struct InteractionApp: App {
    @State private var count = 0
    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("presentation") {
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
