import shutil
import os
import sys
from pathlib import Path
import pytest

@pytest.fixture
def flutter_test_env(tmp_path):
    test_root = tmp_path.resolve()
    
    # Setup source structure
    source_dir = test_root / "source"
    source_dir.mkdir()
    (source_dir / "1. Chapter.md").write_text("Content", encoding="utf-8")
    (source_dir / "X Draft.md").write_text("Draft", encoding="utf-8")
    
    source_assets_images = source_dir / "assets" / "images"
    source_assets_images.mkdir(parents=True)
    (source_assets_images / "img.png").write_text("img", encoding="utf-8")
    
    source_assets_audio = source_dir / "assets" / "audio"
    source_assets_audio.mkdir(parents=True)
    (source_assets_audio / "audio.mp3").write_text("audio", encoding="utf-8")
    
    # Setup other project dirs
    icon_dir = test_root / "icon"
    icon_dir.mkdir()
    (icon_dir / "six-senses.png").write_text("logo", encoding="utf-8")
    (icon_dir / "six-senses-flutter.png").write_text("flutter-icon", encoding="utf-8")
    
    static_images_dir = test_root / "website_project" / "static" / "images"
    static_images_dir.mkdir(parents=True)
    (static_images_dir / "theme-icon.svg").write_text("sun", encoding="utf-8")
    (static_images_dir / "theme-icon-moon.svg").write_text("moon", encoding="utf-8")
    
    # Setup flutter_project dir
    flutter_dir = test_root / "flutter_project"
    flutter_dir.mkdir()
    
    return test_root

def test_copy_flutter_source_files(flutter_test_env):
    from flutter_project.copy_assets import copy_flutter_source_files
    
    test_root = flutter_test_env
    
    # Act
    copy_flutter_source_files(project_root=test_root)
    
    # Assert
    flutter_markdown_dir = test_root / "flutter_project" / "assets" / "markdown"
    flutter_images_dir = test_root / "flutter_project" / "assets" / "images"
    flutter_audio_dir = test_root / "flutter_project" / "assets" / "audio"
    
    assert (flutter_markdown_dir / "1. Chapter.md").exists()
    assert not (flutter_markdown_dir / "X Draft.md").exists()
    assert (flutter_images_dir / "img.png").exists()
    assert (flutter_audio_dir / "audio.mp3").exists()
    assert (flutter_images_dir / "six-senses.png").exists()
    assert (flutter_images_dir / "six-senses-flutter.png").exists()
    assert (flutter_images_dir / "theme-icon.svg").exists()
    assert (flutter_images_dir / "theme-icon-moon.svg").exists()