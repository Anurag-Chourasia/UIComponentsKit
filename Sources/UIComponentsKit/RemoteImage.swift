import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import DesignTokensKit

/// Protocol for asynchronous image data retrieval.
/// Host applications inject network/cached loaders; views remain purely presentational.
public protocol ImageDataLoading: Sendable {
    func loadImageData(from url: URL) async throws -> Data
}

public extension ImageDataLoading {
    /// Convenience alias for image data loading.
    func load(from url: URL) async throws -> Data {
        try await loadImageData(from: url)
    }
}

/// Default URLSession-backed loader used when no custom loader is injected.
public struct DefaultImageDataLoading: ImageDataLoading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func loadImageData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

/// Type-erased closure-backed image data loader for flexible dependency injection in tests and previews.
public struct AnyImageDataLoading: ImageDataLoading {
    private let loader: @Sendable (URL) async throws -> Data

    public init(_ loader: @escaping @Sendable (URL) async throws -> Data) {
        self.loader = loader
    }

    public func loadImageData(from url: URL) async throws -> Data {
        try await loader(url)
    }
}

private struct ImageDataLoaderKey: EnvironmentKey {
    static let defaultValue: (any ImageDataLoading)? = nil
}

public extension EnvironmentValues {
    var imageDataLoader: (any ImageDataLoading)? {
        get { self[ImageDataLoaderKey.self] }
        set { self[ImageDataLoaderKey.self] = newValue }
    }
}

public extension View {
    /// Injects an `ImageDataLoading` provider into the SwiftUI environment.
    func imageDataLoader(_ loader: (any ImageDataLoading)?) -> some View {
        environment(\.imageDataLoader, loader)
    }
}

/// Discrete phase states for an asynchronous remote image load.
public enum RemoteImagePhase: Sendable {
    case empty
    case loading
    case success(Image)
    case failure(Error)

    public var image: Image? {
        if case .success(let image) = self {
            return image
        }
        return nil
    }

    public var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

/// A decoupled, token-friendly remote image component backed by an injected `ImageDataLoading` protocol.
/// Does not depend on direct host networking; pure presentation with cancellation safety.
public struct RemoteImage<Content: View, Placeholder: View>: View {
    @Environment(\.imageDataLoader) private var environmentLoader
    @State private var phase: RemoteImagePhase = .empty

    private let url: URL?
    private let explicitLoader: (any ImageDataLoading)?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    public init(
        url: URL?,
        loader: (any ImageDataLoading)? = nil,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.explicitLoader = loader
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            switch phase {
            case .empty, .loading:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                placeholder()
            }
        }
        .task(id: url) {
            await load()
        }
    }

    @MainActor
    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        phase = .loading
        let activeLoader = explicitLoader ?? environmentLoader ?? DefaultImageDataLoading()

        do {
            let data = try await activeLoader.loadImageData(from: url)
            try Task.checkCancellation()
            if let image = Self.platformImage(from: data) {
                phase = .success(image)
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch is CancellationError {
            // Task cancelled
        } catch {
            if !Task.isCancelled {
                phase = .failure(error)
            }
        }
    }

    private static func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return nil
        #else
        return nil
        #endif
    }
}

extension RemoteImage where Content == Image, Placeholder == LoadingOverlayView {
    /// Convenience initializer using the standard token-driven `LoadingOverlayView` as placeholder.
    public init(
        url: URL?,
        loader: (any ImageDataLoading)? = nil
    ) {
        self.init(
            url: url,
            loader: loader,
            content: { $0 },
            placeholder: { LoadingOverlayView() }
        )
    }
}

extension RemoteImage where Content == Image {
    /// Convenience initializer allowing custom placeholder while defaulting image content to unstyled `Image`.
    public init(
        url: URL?,
        loader: (any ImageDataLoading)? = nil,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: url,
            loader: loader,
            content: { $0 },
            placeholder: placeholder
        )
    }
}

extension RemoteImage where Placeholder == LoadingOverlayView {
    /// Convenience initializer allowing custom content modifier while using `LoadingOverlayView` placeholder.
    public init(
        url: URL?,
        loader: (any ImageDataLoading)? = nil,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            loader: loader,
            content: content,
            placeholder: { LoadingOverlayView() }
        )
    }
}

/// Remote image view vending the full `RemoteImagePhase` (empty, loading, success, failure) to custom content builders.
public struct RemoteImagePhaseView<Content: View>: View {
    @Environment(\.imageDataLoader) private var environmentLoader
    @State private var phase: RemoteImagePhase = .empty

    private let url: URL?
    private let explicitLoader: (any ImageDataLoading)?
    private let content: (RemoteImagePhase) -> Content

    public init(
        url: URL?,
        loader: (any ImageDataLoading)? = nil,
        @ViewBuilder content: @escaping (RemoteImagePhase) -> Content
    ) {
        self.url = url
        self.explicitLoader = loader
        self.content = content
    }

    public var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }

    @MainActor
    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        phase = .loading
        let activeLoader = explicitLoader ?? environmentLoader ?? DefaultImageDataLoading()

        do {
            let data = try await activeLoader.loadImageData(from: url)
            try Task.checkCancellation()
            if let image = Self.platformImage(from: data) {
                phase = .success(image)
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch is CancellationError {
            // Task cancelled
        } catch {
            if !Task.isCancelled {
                phase = .failure(error)
            }
        }
    }

    private static func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        return nil
        #else
        return nil
        #endif
    }
}
