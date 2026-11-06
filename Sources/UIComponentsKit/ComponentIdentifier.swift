import SwiftUI

/// Validated accessibility and UI test identifier representation with explicit ownership namespaces.
///
/// `ComponentIdentifier` is a validated `RawRepresentable` value type rather than a closed enum so that
/// shared UI components (`UIComponentsKit`, `AuthKitUI`) and host applications (`ShowBook`, `myTV`,
/// `Motivation Daily`) can expose typed static members and parameterized builders without accepting
/// arbitrary unvalidated strings in production views.
public struct ComponentIdentifier: RawRepresentable, Hashable, Sendable, CustomStringConvertible {
    /// Ownership domain for a registered or validated component identifier.
    public enum Namespace: String, CaseIterable, Hashable, Sendable {
        case shared
        case auth
        case showBook
        case myTV
        case motivationDaily
    }

    public let rawValue: String
    public let namespace: Namespace

    fileprivate init(registered rawValue: String, namespace: Namespace) {
        self.rawValue = rawValue
        self.namespace = namespace
    }

    /// Initializes a `ComponentIdentifier` only if `rawValue` is a registered static/dynamic identifier
    /// or satisfies the identifier format contract (`[A-Za-z0-9]+([._-][A-Za-z0-9]+)*`).
    public init?(rawValue: String) {
        if let registered = Self.registeredLookup[rawValue] {
            self = registered
            return
        }
        guard let inferredNamespace = Self.inferredDynamicNamespace(for: rawValue) else {
            return nil
        }
        self.rawValue = rawValue
        self.namespace = inferredNamespace
    }

    /// Validates an identifier string against the canonical format contract and associates it with an explicit namespace.
    public init?(validating rawValue: String, namespace: Namespace) {
        guard Self.isValidFormat(rawValue) else {
            return nil
        }
        if let registered = Self.registeredLookup[rawValue], registered.namespace != namespace {
            return nil
        }
        self.rawValue = rawValue
        self.namespace = namespace
    }

    public var description: String {
        rawValue
    }

    public static func == (lhs: ComponentIdentifier, rhs: ComponentIdentifier) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    /// Returns true when `rawValue` is a registered identifier or a valid parameterized identifier.
    public static func isRegistered(_ rawValue: String) -> Bool {
        registeredLookup[rawValue] != nil || inferredDynamicNamespace(for: rawValue) != nil
    }

    /// Returns true when `rawValue` satisfies the lexical identifier format (`[A-Za-z0-9]+([._-][A-Za-z0-9]+)*`).
    public static func isValidFormat(_ rawValue: String) -> Bool {
        guard !rawValue.isEmpty else { return false }
        let scalars = Array(rawValue.unicodeScalars)
        guard isASCIIAlphaNumeric(scalars[0]), isASCIIAlphaNumeric(scalars[scalars.count - 1]) else {
            return false
        }
        var previousWasSeparator = false
        for scalar in scalars {
            if isASCIIAlphaNumeric(scalar) {
                previousWasSeparator = false
            } else if scalar == "." || scalar == "-" || scalar == "_" {
                if previousWasSeparator {
                    return false
                }
                previousWasSeparator = true
            } else {
                return false
            }
        }
        return true
    }

    private static func isASCIIAlphaNumeric(_ scalar: UnicodeScalar) -> Bool {
        (scalar.value >= 48 && scalar.value <= 57)
            || (scalar.value >= 65 && scalar.value <= 90)
            || (scalar.value >= 97 && scalar.value <= 122)
    }

    private static func sanitizeToken(_ token: String, fallback: String) -> String {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidFormat(trimmed) ? trimmed : fallback
    }

    private static func inferredDynamicNamespace(for rawValue: String) -> Namespace? {
        guard isValidFormat(rawValue) else { return nil }
        for prefix in ["book-tile-"] where rawValue.hasPrefix(prefix) {
            let suffix = String(rawValue.dropFirst(prefix.count))
            if isValidFormat(suffix) {
                return .showBook
            }
        }
        for prefix in ["auth.provider.", "auth-provider-"] where rawValue.hasPrefix(prefix) {
            let suffix = String(rawValue.dropFirst(prefix.count))
            if isValidFormat(suffix) {
                return .auth
            }
        }
        return nil
    }
}

public typealias A11yID = ComponentIdentifier

// MARK: - Shared & Developer Settings Identifiers
extension ComponentIdentifier {
    public static let appearanceMenu = ComponentIdentifier(registered: "appearance-menu", namespace: .shared)
    public static let developerAuthentication = ComponentIdentifier(registered: "developer-authentication", namespace: .shared)
    public static let developerOpenApp = ComponentIdentifier(registered: "developer-open-app", namespace: .shared)
    public static let developerPresetEmpty = ComponentIdentifier(registered: "developer-preset-empty", namespace: .shared)
    public static let developerPresetLive = ComponentIdentifier(registered: "developer-preset-live", namespace: .shared)
    public static let developerPresetOffline = ComponentIdentifier(registered: "developer-preset-offline", namespace: .shared)
    public static let developerPresetShowcase = ComponentIdentifier(registered: "developer-preset-showcase", namespace: .shared)
    public static let developerPrivacyPolicy = ComponentIdentifier(registered: "developer-privacy-policy", namespace: .shared)
    public static let developerPurgeCache = ComponentIdentifier(registered: "developer-purge-cache", namespace: .shared)
    public static let developerSupport = ComponentIdentifier(registered: "developer-support", namespace: .shared)
    public static let screenTools = ComponentIdentifier(registered: "screen-tools", namespace: .shared)
    public static let showcaseDemoIndicator = ComponentIdentifier(registered: "showcase-demo-indicator", namespace: .shared)
}

// MARK: - myTV Host Identifiers
extension ComponentIdentifier {
    public static let hideUnavailableStreams = ComponentIdentifier(registered: "hide-unavailable-streams", namespace: .myTV)
}

// MARK: - ShowBook Host Identifiers
extension ComponentIdentifier {
    public static let discoverCategory = ComponentIdentifier(registered: "discover-category", namespace: .showBook)
    public static let discoverScreen = ComponentIdentifier(registered: "discover-screen", namespace: .showBook)
    public static let discoverSortMenu = ComponentIdentifier(registered: "discover-sort-menu", namespace: .showBook)
    public static let searchStateBanner = ComponentIdentifier(registered: "search-state-banner", namespace: .showBook)
    public static let bookmarkButton = ComponentIdentifier(registered: "bookmarkButton", namespace: .showBook)
    public static let bookCoverPreview = ComponentIdentifier(registered: "book-cover-preview", namespace: .showBook)
    public static let bookLayoutMenu = ComponentIdentifier(registered: "book-layout-menu", namespace: .showBook)
    public static let shareCover = ComponentIdentifier(registered: "share-cover", namespace: .showBook)

    public static func bookTile(_ layout: CatalogLayout) -> ComponentIdentifier {
        ComponentIdentifier(registered: "book-tile-\(layout.rawValue)", namespace: .showBook)
    }

    public static func bookTile(_ layout: String) -> ComponentIdentifier {
        let token = sanitizeToken(layout, fallback: CatalogLayout.list.rawValue)
        return ComponentIdentifier(registered: "book-tile-\(token)", namespace: .showBook)
    }
}

// MARK: - Motivation Daily Host Identifiers
extension ComponentIdentifier {
    public static let aboutBackButton = ComponentIdentifier(registered: "about.backButton", namespace: .motivationDaily)
    public static let contentCategoryTabs = ComponentIdentifier(registered: "content.categoryTabs", namespace: .motivationDaily)
    public static let contentMenuButton = ComponentIdentifier(registered: "content.menuButton", namespace: .motivationDaily)
    public static let contentRatioButton = ComponentIdentifier(registered: "content.ratioButton", namespace: .motivationDaily)
    public static let contentSaveButton = ComponentIdentifier(registered: "content.saveButton", namespace: .motivationDaily)
    public static let contentShareButton = ComponentIdentifier(registered: "content.shareButton", namespace: .motivationDaily)
    public static let favoritesCell = ComponentIdentifier(registered: "favorites.cell", namespace: .motivationDaily)
    public static let favoritesDoneButton = ComponentIdentifier(registered: "favorites.doneButton", namespace: .motivationDaily)
    public static let favoritesFullScreenCloseButton = ComponentIdentifier(registered: "favorites.fullScreen.closeButton", namespace: .motivationDaily)
    public static let favoritesFullScreenRatioButton = ComponentIdentifier(registered: "favorites.fullScreen.ratioButton", namespace: .motivationDaily)
    public static let favoritesFullScreenShareButton = ComponentIdentifier(registered: "favorites.fullScreen.shareButton", namespace: .motivationDaily)
    public static let favoritesList = ComponentIdentifier(registered: "favorites.list", namespace: .motivationDaily)
    public static let favoritesRemoveButton = ComponentIdentifier(registered: "favorites.removeButton", namespace: .motivationDaily)
    public static let shareCopyQuoteButton = ComponentIdentifier(registered: "share.copyQuoteButton", namespace: .motivationDaily)
    public static let shareDoneButton = ComponentIdentifier(registered: "share.doneButton", namespace: .motivationDaily)
    public static let shareImageOnlyButton = ComponentIdentifier(registered: "share.imageOnlyButton", namespace: .motivationDaily)
    public static let shareQuoteAndImageButton = ComponentIdentifier(registered: "share.quoteAndImageButton", namespace: .motivationDaily)
    public static let shareQuoteOnlyButton = ComponentIdentifier(registered: "share.quoteOnlyButton", namespace: .motivationDaily)
    public static let shareSaveToPhotosButton = ComponentIdentifier(registered: "share.saveToPhotosButton", namespace: .motivationDaily)
    public static let shareSheet = ComponentIdentifier(registered: "share.sheet", namespace: .motivationDaily)
}

// MARK: - AuthKit Identifiers
extension ComponentIdentifier {
    /// Typed authentication provider cases for `ComponentIdentifier.authProvider(_:)`.
    public enum AuthProviderID: String, CaseIterable, Hashable, Sendable {
        case apple
        case google
        case github
    }

    public static let authAccount = ComponentIdentifier(registered: "auth.account", namespace: .auth)
    public static let authAccountEmail = ComponentIdentifier(registered: "auth.accountEmail", namespace: .auth)
    public static let authAccountResetPassword = ComponentIdentifier(registered: "auth.accountResetPassword", namespace: .auth)
    public static let authConfirmPassword = ComponentIdentifier(registered: "auth.confirmPassword", namespace: .auth)
    public static let authDeleteAccount = ComponentIdentifier(registered: "auth.deleteAccount", namespace: .auth)
    public static let authEmail = ComponentIdentifier(registered: "auth.email", namespace: .auth)
    public static let authError = ComponentIdentifier(registered: "auth.error", namespace: .auth)
    public static let authForgotPassword = ComponentIdentifier(registered: "auth.forgotPassword", namespace: .auth)
    public static let authNotice = ComponentIdentifier(registered: "auth.notice", namespace: .auth)
    public static let authPassword = ComponentIdentifier(registered: "auth.password", namespace: .auth)
    public static let authSignOut = ComponentIdentifier(registered: "auth.signOut", namespace: .auth)
    public static let authSubmit = ComponentIdentifier(registered: "auth.submit", namespace: .auth)
    public static let authSwitchMode = ComponentIdentifier(registered: "auth.switchMode", namespace: .auth)

    public static func authProvider(_ provider: AuthProviderID) -> ComponentIdentifier {
        ComponentIdentifier(registered: "auth.provider.\(provider.rawValue)", namespace: .auth)
    }

    public static func authProvider(_ id: String) -> ComponentIdentifier {
        let token = sanitizeToken(id, fallback: AuthProviderID.apple.rawValue)
        return ComponentIdentifier(registered: "auth.provider.\(token)", namespace: .auth)
    }
}

// MARK: - Registered Identifier Inventory
extension ComponentIdentifier {
    public static let registeredIdentifiers: [ComponentIdentifier] = [
        .appearanceMenu,
        .developerAuthentication,
        .developerOpenApp,
        .developerPresetEmpty,
        .developerPresetLive,
        .developerPresetOffline,
        .developerPresetShowcase,
        .developerPrivacyPolicy,
        .developerPurgeCache,
        .developerSupport,
        .screenTools,
        .showcaseDemoIndicator,
        .hideUnavailableStreams,
        .discoverCategory,
        .discoverScreen,
        .discoverSortMenu,
        .searchStateBanner,
        .bookmarkButton,
        .bookCoverPreview,
        .bookLayoutMenu,
        .shareCover,
        .bookTile(.list),
        .bookTile(.grid),
        .aboutBackButton,
        .contentCategoryTabs,
        .contentMenuButton,
        .contentRatioButton,
        .contentSaveButton,
        .contentShareButton,
        .favoritesCell,
        .favoritesDoneButton,
        .favoritesFullScreenCloseButton,
        .favoritesFullScreenRatioButton,
        .favoritesFullScreenShareButton,
        .favoritesList,
        .favoritesRemoveButton,
        .shareCopyQuoteButton,
        .shareDoneButton,
        .shareImageOnlyButton,
        .shareQuoteAndImageButton,
        .shareQuoteOnlyButton,
        .shareSaveToPhotosButton,
        .shareSheet,
        .authAccount,
        .authAccountEmail,
        .authAccountResetPassword,
        .authConfirmPassword,
        .authDeleteAccount,
        .authEmail,
        .authError,
        .authForgotPassword,
        .authNotice,
        .authPassword,
        .authSignOut,
        .authSubmit,
        .authSwitchMode,
        .authProvider(.apple),
        .authProvider(.google),
        .authProvider(.github)
    ]

    fileprivate static let registeredLookup: [String: ComponentIdentifier] = {
        var table: [String: ComponentIdentifier] = [:]
        for item in registeredIdentifiers {
            table[item.rawValue] = item
        }
        return table
    }()
}

// MARK: - SwiftUI View Modifier
extension View {
    public func accessibilityIdentifier(_ id: ComponentIdentifier) -> some View {
        self.accessibilityIdentifier(id.rawValue)
    }
}
