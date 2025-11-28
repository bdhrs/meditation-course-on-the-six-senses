#!/usr/bin/env python3
"""
Script to copy source files to Flutter app's asset directories.
This is for development purposes to have content available in the app.
"""

import shutil
from pathlib import Path


def copy_source_files():
    """Copy source files to Flutter app's asset directories."""
    project_root = Path(
        __file__
    ).parent.parent  # Go up one level since script is now in flutter_project
    source_dir = project_root / "source"

    # Define destination directories
    flutter_markdown_dir = project_root / "flutter_project" / "assets" / "markdown"
    flutter_images_dir = project_root / "flutter_project" / "assets" / "images"
    flutter_audio_dir = project_root / "flutter_project" / "assets" / "audio"

    print(f"Copying markdown files from {source_dir} to {flutter_markdown_dir}")
    print(f"Copying image assets to {flutter_images_dir}")
    print(f"Copying audio assets to {flutter_audio_dir}")

    # Clean the destination directories
    for dest_dir in [flutter_markdown_dir, flutter_images_dir, flutter_audio_dir]:
        if dest_dir.exists():
            shutil.rmtree(dest_dir)
        dest_dir.mkdir(parents=True, exist_ok=True)

    # Copy all markdown files
    for md_file in source_dir.glob("*.md"):
        if not md_file.name.startswith("X"):  # Skip draft files
            shutil.copy2(md_file, flutter_markdown_dir / md_file.name)
            print(f"Copied {md_file.name}")

    # Copy image assets
    source_images_dir = source_dir / "assets" / "images"
    if source_images_dir.exists():
        for image_file in source_images_dir.iterdir():
            if image_file.is_file():
                shutil.copy2(image_file, flutter_images_dir / image_file.name)
        print("Copied image assets")

    # Copy audio assets
    source_audio_dir = source_dir / "assets" / "audio"
    if source_audio_dir.exists():
        for audio_file in source_audio_dir.iterdir():
            if audio_file.is_file():
                shutil.copy2(audio_file, flutter_audio_dir / audio_file.name)
        print("Copied audio assets")

    # Copy PNG logo file
    logo_png_file = project_root / "icon" / "six-senses.png"
    if logo_png_file.exists():
        shutil.copy2(logo_png_file, flutter_images_dir / "six-senses.png")
        print("Copied PNG logo file")

    # Copy Flutter specific icon
    flutter_icon_file = project_root / "icon" / "six-senses-flutter.png"
    if flutter_icon_file.exists():
        shutil.copy2(flutter_icon_file, flutter_images_dir / "six-senses-flutter.png")
        print("Copied Flutter specific icon")

    # Copy theme icons
    theme_icons_dir = project_root / "website_project" / "static" / "images"
    if theme_icons_dir.exists():
        # Copy sun icon
        sun_icon = theme_icons_dir / "theme-icon.svg"
        if sun_icon.exists():
            shutil.copy2(sun_icon, flutter_images_dir / "theme-icon.svg")
            print("Copied sun icon")

        # Copy moon icon
        moon_icon = theme_icons_dir / "theme-icon-moon.svg"
        if moon_icon.exists():
            shutil.copy2(moon_icon, flutter_images_dir / "theme-icon-moon.svg")
            print("Copied moon icon")

    print("Source files copied successfully!")


if __name__ == "__main__":
    copy_source_files()
