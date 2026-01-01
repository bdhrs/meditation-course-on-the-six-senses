import unittest
from pathlib import Path
import json

class ValidateWebOutput(unittest.TestCase):
    def setUp(self):
        self.output_dir = Path("output/Meditation Course on the Six Senses")

    def test_output_exists(self):
        self.assertTrue(self.output_dir.exists(), "Output directory does not exist. Run build first.")

    def test_essential_files(self):
        essential_files = [
            "index.html",
            "contents.html",
            "404.html",
            "manifest.webmanifest",
            "sw.js",
            "audio-files.json"
        ]
        for f in essential_files:
            with self.subTest(file=f):
                self.assertTrue((self.output_dir / f).exists(), f"{f} is missing from output")

    def test_static_assets(self):
        static_dirs = [
            "static/css",
            "static/js",
            "static/images",
            "static/fonts",
            "static/audio"
        ]
        for d in static_dirs:
            with self.subTest(directory=d):
                self.assertTrue((self.output_dir / d).exists(), f"Static directory {d} is missing")

    def test_index_content(self):
        index_html = (self.output_dir / "index.html").read_text(encoding="utf-8")
        self.assertIn("Meditation Course on the Six Senses", index_html)
        self.assertIn("index.html", index_html)

    def test_audio_files_json(self):
        audio_json_path = self.output_dir / "audio-files.json"
        self.assertTrue(audio_json_path.exists())
        with open(audio_json_path, 'r') as f:
            audio_files = json.load(f)
        self.assertIsInstance(audio_files, list)
        self.assertTrue(len(audio_files) > 0, "No audio files found in audio-files.json")

if __name__ == "__main__":
    unittest.main()
