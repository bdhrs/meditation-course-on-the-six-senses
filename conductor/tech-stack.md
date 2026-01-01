# Technology Stack: Meditation Course on the Six Senses

## Core Technologies
- **Programming Languages:**
  - **Python (3.12+):** Primary language for build scripts, static site generation, and content processing.
  - **Dart:** Primary language for mobile and desktop application logic.
- **Frameworks:**
  - **Flutter:** Used for Android, Linux, (and potentially iOS/Windows/macOS) applications.
  - **MkDocs / Custom Python Generator:** Used for generating the static website from Markdown source.

## Build & Dependency Management
- **Package Manager (Python):** `uv` (Fast Python package installer and resolver).
- **Package Manager (Dart):** `pub`.
- **Orchestration:** `main.py` acts as the central build entry point.

## Data & Content
- **Source Format:** Markdown (`.md`) with custom extensions for Pāḷi quotes and media.
- **Media:** MP3 (Audio), SVG/PNG (Images).
- **Configuration:** `pyproject.toml` (Python), `pubspec.yaml` (Flutter).

## Infrastructure & Deployment
- **Hosting:** GitHub Pages (Static Website).
- **CI/CD:** GitHub Actions (Automated builds for Web, Android, and Linux).

## Future Considerations
- **Cross-Platform Build Independence:** Investigating **Expo (React Native)** to allow building iOS/Windows binaries without native hardware.
