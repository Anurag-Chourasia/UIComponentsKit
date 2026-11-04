import SwiftUI

/// Canonical accessibility and UI test identifier representation.
public struct ComponentIdentifier: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public var description: String {
        rawValue
    }
}

public typealias A11yID = ComponentIdentifier

// MARK: - Developer Settings Identifiers
extension ComponentIdentifier {
    public static let developerAuthentication: ComponentIdentifier = "developer-authentication"
    public static let developerOpenApp: ComponentIdentifier = "developer-open-app"
    public static let developerPresetEmpty: ComponentIdentifier = "developer-preset-empty"
    public static let developerPresetLive: ComponentIdentifier = "developer-preset-live"
    public static let developerPresetOffline: ComponentIdentifier = "developer-preset-offline"
    public static let developerPresetShowcase: ComponentIdentifier = "developer-preset-showcase"
    public static let developerPrivacyPolicy: ComponentIdentifier = "developer-privacy-policy"
    public static let developerPurgeCache: ComponentIdentifier = "developer-purge-cache"
    public static let developerSupport: ComponentIdentifier = "developer-support"
    public static let screenTools: ComponentIdentifier = "screen-tools"
    public static let showcaseDemoIndicator: ComponentIdentifier = "showcase-demo-indicator"
    public static let hideUnavailableStreams: ComponentIdentifier = "hide-unavailable-streams"
}

// MARK: - Navigation & Generic Identifiers
extension ComponentIdentifier {
    public static let appearanceMenu: ComponentIdentifier = "appearance-menu"
    public static let discoverCategory: ComponentIdentifier = "discover-category"
    public static let discoverScreen: ComponentIdentifier = "discover-screen"
    public static let discoverSortMenu: ComponentIdentifier = "discover-sort-menu"
    public static let searchStateBanner: ComponentIdentifier = "search-state-banner"
    public static let bookmarkButton: ComponentIdentifier = "bookmarkButton"
}

// MARK: - Book & Media Identifiers
extension ComponentIdentifier {
    public static let bookCoverPreview: ComponentIdentifier = "book-cover-preview"
    public static let bookLayoutMenu: ComponentIdentifier = "book-layout-menu"
    public static func bookTile(_ layout: String) -> ComponentIdentifier {
        ComponentIdentifier(rawValue: "book-tile-\(layout)")
    }
    public static let shareCover: ComponentIdentifier = "share-cover"
}

// MARK: - Motivation & Quotes Identifiers
extension ComponentIdentifier {
    public static let aboutBackButton: ComponentIdentifier = "about.backButton"
    public static let contentCategoryTabs: ComponentIdentifier = "content.categoryTabs"
    public static let contentMenuButton: ComponentIdentifier = "content.menuButton"
    public static let contentRatioButton: ComponentIdentifier = "content.ratioButton"
    public static let contentSaveButton: ComponentIdentifier = "content.saveButton"
    public static let contentShareButton: ComponentIdentifier = "content.shareButton"
    public static let favoritesCell: ComponentIdentifier = "favorites.cell"
    public static let favoritesDoneButton: ComponentIdentifier = "favorites.doneButton"
    public static let favoritesFullScreenCloseButton: ComponentIdentifier = "favorites.fullScreen.closeButton"
    public static let favoritesFullScreenRatioButton: ComponentIdentifier = "favorites.fullScreen.ratioButton"
    public static let favoritesFullScreenShareButton: ComponentIdentifier = "favorites.fullScreen.shareButton"
    public static let favoritesList: ComponentIdentifier = "favorites.list"
    public static let favoritesRemoveButton: ComponentIdentifier = "favorites.removeButton"
    public static let shareCopyQuoteButton: ComponentIdentifier = "share.copyQuoteButton"
    public static let shareDoneButton: ComponentIdentifier = "share.doneButton"
    public static let shareImageOnlyButton: ComponentIdentifier = "share.imageOnlyButton"
    public static let shareQuoteAndImageButton: ComponentIdentifier = "share.quoteAndImageButton"
    public static let shareQuoteOnlyButton: ComponentIdentifier = "share.quoteOnlyButton"
    public static let shareSaveToPhotosButton: ComponentIdentifier = "share.saveToPhotosButton"
    public static let shareSheet: ComponentIdentifier = "share.sheet"
}

// MARK: - AuthKit Identifiers
extension ComponentIdentifier {
    public static let authAccount: ComponentIdentifier = "auth-account"
    public static let authAccountEmail: ComponentIdentifier = "auth-account-email"
    public static let authAccountResetPassword: ComponentIdentifier = "auth-account-reset-password"
    public static let authConfirmPassword: ComponentIdentifier = "auth-confirm-password"
    public static let authDeleteAccount: ComponentIdentifier = "auth-delete-account"
    public static let authEmail: ComponentIdentifier = "auth-email"
    public static let authError: ComponentIdentifier = "auth-error"
    public static let authForgotPassword: ComponentIdentifier = "auth-forgot-password"
    public static let authNotice: ComponentIdentifier = "auth-notice"
    public static let authPassword: ComponentIdentifier = "auth-password"
    public static let authSignOut: ComponentIdentifier = "auth-sign-out"
    public static let authSubmit: ComponentIdentifier = "auth-submit"
    public static let authSwitchMode: ComponentIdentifier = "auth-switch-mode"
    public static func authProvider(_ id: String) -> ComponentIdentifier {
        ComponentIdentifier(rawValue: "auth-provider-\(id)")
    }
}

// MARK: - SwiftUI View Modifier
extension View {
    public func accessibilityIdentifier(_ id: ComponentIdentifier) -> some View {
        self.accessibilityIdentifier(id.rawValue)
    }
}
