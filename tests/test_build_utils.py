import shutil
import os
import zipfile
from pathlib import Path
import pytest
from paths import ProjectPaths
from build_utils import generate_ebook_source, zip_website, zip_mp3s

@pytest.fixture
def test_env(tmp_path):
    # tmp_path is a built-in pytest fixture that provides a temporary directory
    source_dir = tmp_path / "source"
    source_dir.mkdir()
    
    output_dir = tmp_path / "output"
    output_dir.mkdir()
    
    # Create dummy source files
    (source_dir / "0. Intro.md").write_text("# Intro\nWelcome.", encoding="utf-8")
    (source_dir / "1. Chapter.md").write_text(
        "# Chapter\n"
        "Here is a transcript: %%This is the transcript%%\n"
        "Listen here: ![[meditation.mp3]]\n"
        "See this: ![[image.png]]",
        encoding="utf-8"
    )
    
    # Mock ProjectPaths
    class MockPaths(ProjectPaths):
        def __init__(self, output_markdown_file):
            self.project_name = "Test Project"
            self.output_markdown_file = output_markdown_file
            self.output_site_dir = output_dir / "site"
            self.output_site_zip = output_dir / "site.zip"
            self.output_mp3_zip = output_dir / "mp3s.zip"

    pth = MockPaths(output_dir / "Test Project.md")
    
    # Change current directory to tmp_path for the duration of the test
    old_cwd = os.getcwd()
    os.chdir(tmp_path)
    
    yield pth, tmp_path
    
    os.chdir(old_cwd)

def test_generate_ebook_source_transforms(test_env):
    pth, _ = test_env
    generate_ebook_source(pth)
    
    content = pth.output_markdown_file.read_text(encoding="utf-8")
    
    assert "# 0. Intro" in content
    assert "# 1. Chapter" in content
    assert "<details><summary>Transcript</summary>This is the transcript</details>" in content
    assert "**Listen to: meditation.mp3**" in content
    assert "![image.png](Test%20Project/assets/images/image.png)" in content

def test_zip_website(test_env):
    pth, _ = test_env
    site_dir = pth.output_site_dir
    site_dir.mkdir(parents=True)
    (site_dir / "index.html").write_text("Test", encoding="utf-8")
    
    zip_website(pth)
    
    assert pth.output_site_zip.exists()
    with zipfile.ZipFile(pth.output_site_zip, 'r') as zipf:
        assert "index.html" in zipf.namelist()

def test_zip_mp3s(test_env):
    pth, _ = test_env
    audio_dir = pth.output_site_dir / "static" / "audio"
    audio_dir.mkdir(parents=True)
    (audio_dir / "test.mp3").write_text("dummy mp3 content", encoding="utf-8")
    
    zip_mp3s(pth)
    
    assert pth.output_mp3_zip.exists()
    with zipfile.ZipFile(pth.output_mp3_zip, 'r') as zipf:
        assert "test.mp3" in zipf.namelist()