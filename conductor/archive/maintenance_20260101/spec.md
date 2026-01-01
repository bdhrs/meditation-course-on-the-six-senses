# Track Specification: Comprehensive Maintenance and Consistency Check

## Goal
To ensure all course content (Markdown source) adheres to the strict project conventions and that the build system faithfully reproduces this content across all platforms (Web, App, Ebook).

## Requirements

### 1. Markdown Source Audit
- **Pāḷi Quotes:** Verify that all Pāḷi terms and quotes are correctly formatted (e.g., using specific CSS classes or blockquote styles as defined in `product-guidelines.md`).
- **MP3 Links:** Verify that every chapter has a valid link to its corresponding guided meditation MP3.
- **Section Completeness:** Ensure every chapter contains the mandatory sections:
    - Guided Meditation & Transcript
    - Questions and Answers
    - Further Reading
    - "Make Corrections" Link
- **Broken Links:** Scan for and identify any broken internal or external links.

### 2. Build System Verification
- **Asset Propagation:** Verify that `main.py` and `build_utils.py` correctly copy new/updated assets to the `output/` directory.
- **Mobile Assets:** Verify that `flutter_project/copy_assets.py` correctly syncs the `source/` content to the Flutter assets directory.

### 3. Output Validation
- **Web:** Build the site locally and verify a sample of pages.
- **App:** Build the Android APK (if environment permits) or verify the asset structure in the Flutter project.

## Acceptance Criteria
- A report listing any inconsistencies found in the source markdown.
- All identified critical inconsistencies (missing MP3s, broken structure) are fixed.
- The build process completes without error (`uv run main.py --mode offline`).