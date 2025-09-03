#!/usr/bin/env python3
"""
Script to copy source files to Flutter app's documents directory.
This is for development purposes to have content available in the app.
"""

import shutil
from pathlib import Path

def copy_source_files():
    """Copy source files to Flutter app's documents directory."""
    project_root = Path(__file__).parent
    source_dir = project_root / "source"
    flutter_docs_dir = project_root / "flutter_project" / "assets" / "documents"
    
    print(f"Copying files from {source_dir} to {flutter_docs_dir}")
    
    # Clean the destination directory
    if flutter_docs_dir.exists():
        shutil.rmtree(flutter_docs_dir)
    
    # Create the destination directory
    flutter_docs_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy all markdown files
    for md_file in source_dir.glob("*.md"):
        if not md_file.name.startswith("X"):  # Skip draft files
            shutil.copy2(md_file, flutter_docs_dir / md_file.name)
            print(f"Copied {md_file.name}")
    
    # Copy assets directory
    source_assets_dir = source_dir / "assets"
    if source_assets_dir.exists():
        shutil.copytree(source_assets_dir, flutter_docs_dir / "assets")
        print("Copied assets directory")
    
    # Copy logo file
    logo_file = project_root / "icon" / "six-senses.svg"
    if logo_file.exists():
        logo_dest_dir = flutter_docs_dir / "assets" / "images"
        logo_dest_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(logo_file, logo_dest_dir / "six-senses.svg")
        print("Copied logo file")
    
    # Copy theme icons
    theme_icons_dir = project_root / "website_project" / "static" / "images"
    if theme_icons_dir.exists():
        logo_dest_dir = flutter_docs_dir / "assets" / "images"
        logo_dest_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy sun icon
        sun_icon = theme_icons_dir / "theme-icon.svg"
        if sun_icon.exists():
            shutil.copy2(sun_icon, logo_dest_dir / "theme-icon.svg")
            print("Copied sun icon")
        
        # Copy moon icon
        moon_icon = theme_icons_dir / "theme-icon-moon.svg"
        if moon_icon.exists():
            shutil.copy2(moon_icon, logo_dest_dir / "theme-icon-moon.svg")
            print("Copied moon icon")
    
    print("Source files copied successfully!")

if __name__ == "__main__":
    copy_source_files()