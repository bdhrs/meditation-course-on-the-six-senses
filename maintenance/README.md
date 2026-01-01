# Maintenance Scripts

This folder contains scripts for verifying the integrity of the project's content, assets, and build outputs.

**Note:** All scripts should be run from the **project root directory** to ensure paths are resolved correctly.

## Scripts

### 1. Content Audit
Checks Markdown source files for:
- Unformatted Pāḷi terms (italics or links required)
- Missing MP3s and transcripts
- Missing mandatory sections (Q&A, References)
- Broken links
```bash
uv run python maintenance/audit_content.py
```

### 2. Output Validation
Verifies the integrity of the web build output (e.g., presence of `index.html`, assets, service workers).
```bash
# Run after building the website
uv run python maintenance/validate_output.py
```

### 3. Flutter Asset Validation
Checks that the Flutter project has the correct asset structure and that `pubspec.yaml` is correctly configured.
```bash
uv run --with PyYAML python maintenance/validate_flutter_assets.py
```

### 4. Unit Tests
All tests are located in the `tests/` directory and use the standard `pytest` framework.
```bash
uv run pytest
```
You can also run specific test files:
```bash
uv run pytest tests/test_build_utils.py
```

### 5. Markdown Pattern Checks
Runs regex checks on markdown files (used by the build process).
```bash
uv run python maintenance/check_markdown_patterns.py
```
