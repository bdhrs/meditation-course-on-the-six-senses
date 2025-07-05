# Project Overview

This document provides an overview of the project structure and key components within the `/home/bodhirasa/Code/six-senses` directory.

## Root Directory

The root directory contains several important files and subdirectories:

- `plan.md`: Outlines the project plan for converting a MkDocs site into a Progressive Web App (PWA).
- `README.md`: Provides instructions on how to build the project locally.
- `main.py`: Contains the main function to export the course.
- `make_mkdocs.py`: Includes functions for building the MkDocs site, copying files, and managing assets.
- `markdown_to_html.py`: Converts markdown content to HTML and handles audio links.
- `paths.py`: Defines the `ProjectPaths` data class for managing file paths.
- `pyproject.toml`: Lists project dependencies and configurations.

## Subdirectories

### `flet_project/`
- Contains Flutter-related files and directories.

### `flutter_project/`
- Contains Flutter project files, including Android and iOS specific configurations.

### `output/`
- Stores the generated output of the project, including the MkDocs site and other assets.

### `waveform_project/`
- Contains waveform-related files and backups.

### `mkdocs_project/`
- Holds the MkDocs project files, including CSS, JS, and images.

### `storage/`
- Used for storing data files.

## Key Functions

- `export_course()` (in `main.py`): Main function to initiate the course export process.
- `copy_files()`, `make_index()`, `process_md_files()`, `convert_audio_link()`, `convert_meditation_instruction()`, `convert_links()`, `build_mkdocs_site()`, `zip_mkdocs()` (in `make_mkdocs.py`): Functions for building and managing the MkDocs site.
- `replace_audio_links()`, `add_header_anchors()`, `convert_markdown_to_html()`, `convert_html_to_ebooks()`, `zip_mp3s()` (in `markdown_to_html.py`): Functions for converting markdown to HTML and handling audio files.

## Next Steps

To proceed with the project, focus on understanding the roles of each file and function as outlined above. This will help in making informed decisions about further development or modifications.
