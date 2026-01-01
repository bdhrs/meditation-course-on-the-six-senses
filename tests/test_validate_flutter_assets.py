import unittest
from pathlib import Path
import yaml

class ValidateFlutterAssets(unittest.TestCase):
    def setUp(self):
        self.flutter_dir = Path("flutter_project")
        self.pubspec_path = self.flutter_dir / "pubspec.yaml"

    def test_pubspec_exists(self):
        self.assertTrue(self.pubspec_path.exists())

    def test_asset_directories_exist(self):
        asset_dirs = [
            "assets/markdown",
            "assets/images",
            "assets/audio"
        ]
        for d in asset_dirs:
            with self.subTest(directory=d):
                self.assertTrue((self.flutter_dir / d).exists(), f"Asset directory {d} is missing")

    def test_pubspec_assets_configuration(self):
        with open(self.pubspec_path, 'r') as f:
            pubspec = yaml.safe_load(f)
        
        flutter_config = pubspec.get('flutter', {})
        assets = flutter_config.get('assets', [])
        
        expected_assets = [
            "assets/markdown/",
            "assets/images/",
            "assets/audio/"
        ]
        
        for expected in expected_assets:
            self.assertIn(expected, assets, f"Pubspec is missing asset entry: {expected}")

    def test_markdown_assets_not_empty(self):
        md_dir = self.flutter_dir / "assets" / "markdown"
        md_files = list(md_dir.glob("*.md"))
        self.assertTrue(len(md_files) > 0, "No markdown files found in Flutter assets")
        # Check for non-X files
        non_x_files = [f for f in md_files if not f.name.startswith('X')]
        self.assertTrue(len(non_x_files) > 0, "No non-draft markdown files found in Flutter assets")

if __name__ == "__main__":
    unittest.main()
