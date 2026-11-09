import SwiftUI
import DesignTokensKit
import LocalizationKit

/// A localized, token-driven playback surface view.
/// Integrates playback state (play, pause, stop, replay, live, mute) with caller-owned media content.
public struct PlaybackSurfaceView<MediaContent: View>: View {
    private let isPlaying: Bool
    private let isLive: Bool
    private let isMuted: Bool
    private let context: CommonStrings
    private let onPlayPause: () -> Void
    private let onMuteToggle: (() -> Void)?
    private let onReplay: (() -> Void)?
    private let onStop: (() -> Void)?
    private let mediaContent: MediaContent

    public init(
        isPlaying: Bool,
        isLive: Bool = false,
        isMuted: Bool = false,
        context: CommonStrings = .shared,
        onPlayPause: @escaping () -> Void,
        onMuteToggle: (() -> Void)? = nil,
        onReplay: (() -> Void)? = nil,
        onStop: (() -> Void)? = nil,
        @ViewBuilder mediaContent: () -> MediaContent
    ) {
        self.isPlaying = isPlaying
        self.isLive = isLive
        self.isMuted = isMuted
        self.context = context
        self.onPlayPause = onPlayPause
        self.onMuteToggle = onMuteToggle
        self.onReplay = onReplay
        self.onStop = onStop
        self.mediaContent = mediaContent()
    }

    public var body: some View {
        ZStack {
            mediaContent
                .background(\.black)

            VStack(spacing: \.zero) {
                HStack(spacing: \.s8) {
                    if isLive {
                        liveBadge
                    }
                    Spacer(minLength: 0)
                    if let onMuteToggle {
                        muteButton(action: onMuteToggle)
                    }
                }
                .padding(\.medium)

                Spacer(minLength: 0)

                HStack(spacing: \.s16) {
                    if let onReplay {
                        replayButton(action: onReplay)
                    }
                    playPauseButton
                    if let onStop {
                        stopButton(action: onStop)
                    }
                }
                .padding(\.medium)
            }
        }
        .cornerRadius(\.cardRadius)
        .clipped()
        .accessibilityElement(children: .contain)
    }

    private var liveBadge: some View {
        HStack(spacing: \.s4) {
            Circle()
                .fill(\.red)
                .frame(size: \.s8)
            Text(context.playbackLive)
                .font(\.caption2)
                .bold()
                .foregroundStyle(\.white)
        }
        .padding(.horizontal, \.s8)
        .padding(.vertical, \.s4)
        .background(\.black, opacity: \.p0_7)
        .cornerRadius(\.r8)
        .accessibilityLabel(Text(context.playbackLive))
    }

    private var playPauseButton: some View {
        let symbolName = isPlaying ? PlaybackSymbols.pause : PlaybackSymbols.play
        return Button(action: onPlayPause) {
            Image(systemName: symbolName)
                .font(\.title2)
                .foregroundStyle(\.white)
                .frame(width: \.touchTargetStandard, height: \.touchTargetStandard)
                .background(\.black, opacity: \.p0_5)
                .clipShape(Circle())
        }
        .accessibilityLabel(Text(isPlaying ? context.playbackPause : context.playbackPlay))
    }

    private func muteButton(action: @escaping () -> Void) -> some View {
        let symbolName = isMuted ? PlaybackSymbols.mute : PlaybackSymbols.unmute
        return Button(action: action) {
            Image(systemName: symbolName)
                .font(\.subheadline)
                .foregroundStyle(\.white)
                .frame(width: \.touchTargetMin, height: \.touchTargetMin)
                .background(\.black, opacity: \.p0_5)
                .clipShape(Circle())
        }
        .accessibilityLabel(Text(isMuted ? context.playbackUnmute : context.playbackMute))
    }

    private func replayButton(action: @escaping () -> Void) -> some View {
        let symbolName = PlaybackSymbols.replay
        return Button(action: action) {
            Image(systemName: symbolName)
                .font(\.subheadline)
                .foregroundStyle(\.white)
                .frame(width: \.touchTargetMin, height: \.touchTargetMin)
                .background(\.black, opacity: \.p0_5)
                .clipShape(Circle())
        }
        .accessibilityLabel(Text(context.playbackReplay))
    }

    private func stopButton(action: @escaping () -> Void) -> some View {
        let symbolName = PlaybackSymbols.stop
        return Button(action: action) {
            Image(systemName: symbolName)
                .font(\.subheadline)
                .foregroundStyle(\.white)
                .frame(width: \.touchTargetMin, height: \.touchTargetMin)
                .background(\.black, opacity: \.p0_5)
                .clipShape(Circle())
        }
        .accessibilityLabel(Text(context.playbackStop))
    }
}

private enum PlaybackSymbols {
    static let play = "play.fill"
    static let pause = "pause.fill"
    static let mute = "speaker.slash.fill"
    static let unmute = "speaker.wave.2.fill"
    static let replay = "arrow.counterclockwise"
    static let stop = "stop.fill"
}

extension PlaybackSurfaceView where MediaContent == Color {
    public init(
        isPlaying: Bool,
        isLive: Bool = false,
        isMuted: Bool = false,
        context: CommonStrings = .shared,
        onPlayPause: @escaping () -> Void,
        onMuteToggle: (() -> Void)? = nil,
        onReplay: (() -> Void)? = nil,
        onStop: (() -> Void)? = nil
    ) {
        self.init(
            isPlaying: isPlaying,
            isLive: isLive,
            isMuted: isMuted,
            context: context,
            onPlayPause: onPlayPause,
            onMuteToggle: onMuteToggle,
            onReplay: onReplay,
            onStop: onStop,
            mediaContent: { Color.black }
        )
    }
}
