#!/usr/bin/env python3
"""Initial IOS-56 lexical checks, IOS-64 ComponentIdentifier contract validation, and cross-repository coverage inventory.

Exit 1 for findings, 2 for incomplete coverage. Existing violations are reported,
never silently converted into a passing baseline. Scope is explicit in the report.
"""
import argparse
import json
import re
from pathlib import Path

IDENTIFIER_FORMAT_RE = re.compile(r"^[A-Za-z0-9]+(?:[._-][A-Za-z0-9]+)*$")

REGISTERED_COMPONENT_MEMBERS = {
    "appearanceMenu",
    "developerAuthentication",
    "developerOpenApp",
    "developerPresetEmpty",
    "developerPresetLive",
    "developerPresetOffline",
    "developerPresetShowcase",
    "developerPrivacyPolicy",
    "developerPurgeCache",
    "developerSupport",
    "screenTools",
    "showcaseDemoIndicator",
    "hideUnavailableStreams",
    "discoverCategory",
    "discoverScreen",
    "discoverSortMenu",
    "searchStateBanner",
    "bookmarkButton",
    "bookCoverPreview",
    "bookLayoutMenu",
    "shareCover",
    "bookTile",
    "aboutBackButton",
    "contentCategoryTabs",
    "contentMenuButton",
    "contentRatioButton",
    "contentSaveButton",
    "contentShareButton",
    "favoritesCell",
    "favoritesDoneButton",
    "favoritesFullScreenCloseButton",
    "favoritesFullScreenRatioButton",
    "favoritesFullScreenShareButton",
    "favoritesList",
    "favoritesRemoveButton",
    "shareCopyQuoteButton",
    "shareDoneButton",
    "shareImageOnlyButton",
    "shareQuoteAndImageButton",
    "shareQuoteOnlyButton",
    "shareSaveToPhotosButton",
    "shareSheet",
    "authAccount",
    "authAccountEmail",
    "authAccountResetPassword",
    "authConfirmPassword",
    "authDeleteAccount",
    "authEmail",
    "authError",
    "authForgotPassword",
    "authNotice",
    "authPassword",
    "authSignOut",
    "authSubmit",
    "authSwitchMode",
    "authProvider",
}


def tokens(source):
    """Skip Swift comments while preserving literals and line locations."""
    result = []
    index = 0
    line = 1
    while index < len(source):
        start = index
        if source.startswith("//", index):
            index = source.find("\n", index)
            if index < 0:
                break
        elif source.startswith("/*", index):
            depth = 1
            index += 2
            while index < len(source) and depth:
                if source.startswith("/*", index):
                    depth += 1
                    index += 2
                elif source.startswith("*/", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
        else:
            match = re.match(r'(#+)?("""|")', source[index:])
            if match:
                hashes = match[1] or ""
                delimiter = match[2] + hashes
                index += len(match[0])
                while index < len(source):
                    if source.startswith(delimiter, index):
                        index += len(delimiter)
                        break
                    if source[index] == "\\" and not hashes:
                        index += 2
                    else:
                        index += 1
                result.append(("string", source[start:index], line))
            else:
                match = re.match(r'[A-Za-z_][A-Za-z_0-9]*|\S', source[index:])
                if match:
                    index += len(match[0])
                    result.append(("code", match[0], line))
                else:
                    index += 1
        line += source[start:index].count("\n")
    return result


def unquote_swift_string(raw):
    """Extract content of a single-line or multiline Swift string literal."""
    match = re.match(r'^(#+)?("""|")(.*)\2(?:\1)?$', raw, re.DOTALL)
    return match[3] if match else ""


def call_arguments(following):
    """Return tokens inside balanced parentheses starting at following[0] == '('."""
    if not following or following[0][0] != "code" or following[0][1] != "(":
        return []
    depth = 0
    captured = []
    for item in following:
        if item[0] == "code" and item[1] == "(":
            depth += 1
            if depth == 1:
                continue
        elif item[0] == "code" and item[1] == ")":
            depth -= 1
            if depth == 0:
                break
        if depth >= 1:
            captured.append(item)
    return captured


def source_findings(source, owner, path):
    stream = tokens(source)
    findings = []
    is_identifier_owner = path.endswith("UIComponentsKit/ComponentIdentifier.swift")

    def add(rule, token):
        findings.append({"rule": rule, "line": token[2], "path": path, "scope": owner})

    for index, token in enumerate(stream):
        if token[0] != "code":
            continue
        name = token[1]
        following = stream[index + 1:]
        if name == "import" and following:
            dependency = following[0][1]
            if owner in ("FoundationKit", "CommonNetworkingKit") and dependency in ("SwiftUI", "UIKit", "AppKit"):
                add("nonvisual_import", token)
            if "/Domain/" in "/" + path and dependency in ("SwiftUI", "UIKit", "AppKit", "LocalizationKit"):
                add("domain_presentation_import", token)
            if owner == "AuthKit" and "/AuthKitUI/" in "/" + path and dependency in ("AuthKitSupabase", "Supabase"):
                add("auth_ui_provider_import", token)
        if owner == "DesignTokensKit":
            continue
        if name in ("systemName", "systemImage") and following and following[0][1] == ":":
            # Catch literals on either side of a ternary, until the argument ends.
            for argument in following[1:]:
                if argument[0] == "code" and argument[1] in (",", ")"):
                    break
                if argument[0] == "string":
                    add("raw_symbol_argument", argument)
        if name == "accessibilityIdentifier" and len(following) >= 2 and following[0][1] == "(":
            args = call_arguments(following)
            if args:
                if args[0][0] == "string":
                    add("raw_accessibility_identifier", args[0])
                elif args[0][0] == "code" and args[0][1] == "." and len(args) >= 2 and args[1][0] == "code":
                    member = args[1][1]
                    if member == "init":
                        add("indirect_component_identifier", args[1])
                    elif member not in REGISTERED_COMPONENT_MEMBERS:
                        add("unknown_component_identifier", args[1])
                elif (
                    len(args) >= 3
                    and args[0][0] == "code"
                    and args[0][1] in ("ComponentIdentifier", "A11yID")
                    and args[1][0] == "code"
                    and args[1][1] == "."
                    and args[2][0] == "code"
                ):
                    member = args[2][1]
                    if member != "init" and member not in REGISTERED_COMPONENT_MEMBERS:
                        add("unknown_component_identifier", args[2])
        if name in ("ComponentIdentifier", "A11yID"):
            if not is_identifier_owner and following and following[0][1] == "(":
                add("indirect_component_identifier", token)
                for arg in call_arguments(following):
                    if arg[0] == "string":
                        value = unquote_swift_string(arg[1])
                        if "\\(" not in value and not IDENTIFIER_FORMAT_RE.match(value):
                            add("invalid_component_identifier_format", arg)
            elif (
                not is_identifier_owner
                and len(following) >= 2
                and following[0][0] == "code"
                and following[0][1] == "."
                and following[1][0] == "code"
            ):
                member = following[1][1]
                if member == "init":
                    add("indirect_component_identifier", following[1])
            elif (
                not is_identifier_owner
                and index >= 1
                and stream[index - 1][0] == "code"
                and stream[index - 1][1] == ":"
                and len(following) >= 2
                and following[0][0] == "code"
                and following[0][1] == "="
                and following[1][0] == "string"
            ):
                add("indirect_component_identifier", following[1])
                value = unquote_swift_string(following[1][1])
                if "\\(" not in value and not IDENTIFIER_FORMAT_RE.match(value):
                    add("invalid_component_identifier_format", following[1])
        if name in ("bookTile", "authProvider") and following and following[0][1] == "(":
            for arg in call_arguments(following):
                if arg[0] == "string":
                    value = unquote_swift_string(arg[1])
                    if "\\(" not in value and not IDENTIFIER_FORMAT_RE.match(value):
                        add("invalid_component_identifier_format", arg)
        if is_identifier_owner and name == "registered" and len(following) >= 2 and following[0][1] == ":":
            if following[1][0] == "string":
                value = unquote_swift_string(following[1][1])
                if "\\(" not in value and not IDENTIFIER_FORMAT_RE.match(value):
                    add("invalid_component_identifier_format", following[1])
        if name in ("Color", "UIColor", "NSColor") and len(following) >= 3:
            if following[0][1] == "(" and following[1][1] in ("red", "white", "hue", "hex") and following[2][1] == ":":
                add("inline_color_value", token)
    return findings


def scan(root, policy, scopes):
    report = {"revision": policy["revision"], "coverage": [], "findings": [],
              "errors": [], "limits": policy["coverage_limits"]}
    for owner in scopes:
        folder = root / policy["scopes"][owner]
        if not folder.is_dir():
            report["errors"].append(f"Missing scope {owner}: {folder}")
            continue
        swift = sorted(folder.rglob("*.swift"))
        assets = sorted(folder.rglob("*.colorset/Contents.json"))
        report["coverage"].append({"scope": owner, "root": policy["scopes"][owner],
                                   "swift_files": len(swift), "color_assets": len(assets),
                                   "generated_swift_files": sum("Generated" in p.parts for p in swift)})
        for file in swift:
            report["findings"].extend(source_findings(file.read_text(), owner, file.relative_to(root).as_posix()))
        for file in assets:
            relative = file.relative_to(root).as_posix()
            try:
                json.loads(file.read_text())
            except (ValueError, OSError) as error:
                report["errors"].append(f"Invalid asset {relative}: {error}")
            if owner != "DesignTokensKit":
                colorset_name = file.parent.name
                if colorset_name not in ("AccentColor.colorset", "LaunchBackground.colorset"):
                    report["findings"].append({"rule": "color_asset_outside_tokens", "line": 1,
                                               "path": relative, "scope": owner})
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--workspace-root", type=Path, required=True)
    parser.add_argument("--policy", type=Path, default=Path(__file__).with_name("architecture-policy.json"))
    parser.add_argument("--scope", action="append", help="Explicit subset; omitted means every declared scope")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    policy = json.loads(args.policy.read_text())
    scopes = args.scope or list(policy["scopes"])
    unknown = set(scopes) - policy["scopes"].keys()
    if unknown:
        parser.error(f"Unknown scopes: {sorted(unknown)}")
    report = scan(args.workspace_root, policy, scopes)
    payload = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(payload)
    else:
        print(payload, end="")
    print(f"Scopes: {len(report['coverage'])}; findings: {len(report['findings'])}; coverage errors: {len(report['errors'])}")
    return 2 if report["errors"] else 1 if report["findings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
