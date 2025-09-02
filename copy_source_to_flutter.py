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
    
    print("Source files copied successfully!")

if __name__ == "__main__":
    copy_source_files()