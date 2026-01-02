# Implementation Plan: Automated AI Proofreading of Course Content

## Phase 1: Infrastructure & Configuration
- [x] Task: Create `config_utils.py` for reusable `config.ini` management
- [x] Task: Add `config.ini` to `.gitignore`
- [x] Task: Install `openrouter` using `uv add openrouter`
- [x] Task: Conductor - User Manual Verification 'Infrastructure' (Protocol in workflow.md)

## Phase 2: Proof of Concept (PoC)
- [x] Task: Implement basic OpenRouter API connectivity in `maintenance/proofread_content.py`
- [x] Task: Implement Markdown parsing to extract prose and transcripts (ignoring Pāḷi blocks)
- [x] Task: Develop and refine the "Strict Voice" prompt for the LLM
- [x] Task: Test script on a single sample file and verify output format in `maintenance/proofread_report.txt`
- [x] Task: Conductor - User Manual Verification 'PoC' (Handled continuously)

## Phase 3: Full Course Processing
- [x] Task: Implement batch processing for all files in `source/` (respecting rate limits)
- [x] Task: Implement error handling and progress logging
- [x] Task: Execute full audit and generate final `maintenance/proofread_report.txt`
- [ ] Task: Conductor - User Manual Verification 'Full Course Processing' (Protocol in workflow.md)
