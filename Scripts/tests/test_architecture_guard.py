import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "check_architecture.py"
spec = importlib.util.spec_from_file_location("architecture_guard", SCRIPT)
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


class ArchitectureGuardTests(unittest.TestCase):
    def rules(self, source, owner="AuthKit", path="AuthKit/Sources/AuthKitUI/Example.swift"):
        return {item["rule"] for item in guard.source_findings(source, owner, path)}

    def test_auth_ui_raw_symbols_identifiers_and_provider_import_are_detected(self):
        source = '''import AuthKitSupabase
        Image(systemName: "person.crop.circle")
        Label("Account", systemImage: selected ? "checkmark" : "circle")
        view.accessibilityIdentifier("auth.account")'''
        self.assertEqual(self.rules(source), {"auth_ui_provider_import", "raw_symbol_argument",
                                              "raw_accessibility_identifier"})

    def test_runtime_placeholder_color_is_not_exempted_as_fixture_pixels(self):
        self.assertIn("inline_color_value", self.rules(
            "let colors = [UIColor(red: 0.10, green: 0.12, blue: 0.22, alpha: 1).cgColor]",
            "MotivationDaily", "Motivation Daily/MotivationDaily/Presentation/Shared/ImageLoader.swift"))

    def test_data_ids_urls_diagnostics_and_comments_are_not_ui_violations(self):
        source = r'''let key = "favoriteQuotes"
        let url = "https://example.com/api//v1"
        logger.log("Image(systemName: \"wifi.slash\")")
        let response = #"{"systemName":"server.field","id":"quote-1"}"#
        // Image(systemName: "wifi.slash")
        /* nested /* UIColor(red: 1) */ Image(systemName: "wifi.slash") */
        Image(\.wifiSlash)
        view.accessibilityIdentifier(.developerSupport)'''
        self.assertEqual(self.rules(source), set())

    def test_indirect_and_invalid_component_identifiers_are_detected(self):
        source = '''
        let raw = ComponentIdentifier(rawValue: "custom-id")
        let alias = A11yID(rawValue: "bad id!")
        let literal: ComponentIdentifier = "another-id"
        view.accessibilityIdentifier(.unregisteredControl)
        view.accessibilityIdentifier(.bookTile("invalid layout!"))
        '''
        self.assertEqual(
            self.rules(source, "ShowBook", "ShowBook/ShowBook/View/Example.swift"),
            {
                "indirect_component_identifier",
                "invalid_component_identifier_format",
                "unknown_component_identifier",
            },
        )

    def test_registered_static_and_dynamic_component_identifiers_are_allowed(self):
        source = '''
        view.accessibilityIdentifier(.developerOpenApp)
        view.accessibilityIdentifier(.bookTile(layout.rawValue))
        view.accessibilityIdentifier(.authProvider("google"))
        '''
        self.assertEqual(self.rules(source, "ShowBook", "ShowBook/ShowBook/View/Example.swift"), set())

    def test_approved_token_owner_keeps_color_and_symbol_definitions(self):
        self.assertEqual(self.rules('Color(red: 1, green: 0, blue: 0); Image(systemName: "star")',
                                    "DesignTokensKit", "DesignTokensKit/Sources/Theme.swift"), set())

    def test_domain_and_nonvisual_import_directions(self):
        self.assertIn("domain_presentation_import", self.rules("import SwiftUI", "MyTV", "MyTV/myTV/Domain/Channel.swift"))
        self.assertIn("domain_presentation_import", self.rules("import LocalizationKit", "MotivationDaily", "MotivationDaily/Domain/Source.swift"))
        self.assertIn("nonvisual_import", self.rules("import UIKit", "FoundationKit", "FoundationKit/Sources/Utility.swift"))
        self.assertEqual(self.rules('let diagnostic = "import UIKit"', "FoundationKit", "Utility.swift"), set())

    def test_generated_sources_and_asset_values_are_inventoried_without_skips(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            generated = root / "Host/Generated"
            generated.mkdir(parents=True)
            (generated / "Output.swift").write_text('Image(systemName: "star")')
            asset = root / "Host/Brand.colorset"
            asset.mkdir()
            (asset / "Contents.json").write_text(json.dumps({"colors": []}))
            policy = {"revision": "test", "scopes": {"Host": "Host"}, "coverage_limits": []}
            report = guard.scan(root, policy, ["Host"])
            self.assertEqual(report["coverage"][0]["generated_swift_files"], 1)
            self.assertEqual(report["coverage"][0]["color_assets"], 1)
            self.assertEqual({x["rule"] for x in report["findings"]},
                             {"raw_symbol_argument", "color_asset_outside_tokens"})

    def test_missing_scope_fails_closed_instead_of_reporting_zero_violations(self):
        with tempfile.TemporaryDirectory() as temporary:
            result = subprocess.run([sys.executable, str(SCRIPT), "--workspace-root", temporary,
                                     "--scope", "UIComponentsKit"], capture_output=True, text=True)
            self.assertEqual(result.returncode, 2)
            self.assertIn("Missing scope UIComponentsKit", result.stdout)

    def test_line_locations_survive_multiline_strings_and_comments(self):
        source = 'let payload = """\nnot code\n"""\n/* comment\n */\nImage(systemName: "star")'
        findings = guard.source_findings(source, "Host", "Host/Example.swift")
        self.assertEqual(findings[0]["line"], 6)


if __name__ == "__main__":
    unittest.main()
