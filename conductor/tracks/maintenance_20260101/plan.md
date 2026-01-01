# Track Plan: Comprehensive Maintenance and Consistency Check

## Phase 1: Analysis & Tooling

- [ ] Task: Create a validation script (`scripts/validate_content.py`) to audit all `source/*.md` files for mandatory sections (MP3s, Pāḷi quotes, Q&A).
- [ ] Task: Run the validation script and generate a `validation_report.md` listing all issues.
- [ ] Task: Conductor - User Manual Verification 'Analysis & Tooling' (Protocol in workflow.md)

## Phase 2: Content Fixes

- [ ] Task: Review `validation_report.md` and fix all 'Missing MP3' errors in the source markdown files.
- [ ] Task: Fix all 'Missing Section' errors (Q&A, Further Reading, etc.) where content is available or mark as TODO.
- [ ] Task: Fix all broken internal and external links identified in the report.
- [ ] Task: Conductor - User Manual Verification 'Content Fixes' (Protocol in workflow.md)

## Phase 3: Build & Integration Verification

- [ ] Task: Run the full offline build (`uv run main.py --mode offline`) and verify it completes successfully.
- [ ] Task: Verify that the `flutter_project/assets/markdown` directory matches the updated `source/` directory (checking `flutter_project/copy_assets.py` behavior).
- [ ] Task: Conductor - User Manual Verification 'Build & Integration Verification' (Protocol in workflow.md)