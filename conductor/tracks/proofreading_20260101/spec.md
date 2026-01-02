# Specification: Automated AI Proofreading of Course Content

## Overview
This track implements an automated proofreading system for the "Meditation Course on the Six Senses." A Python script will leverage an LLM via OpenRouter to identify and suggest corrections for spelling and grammar errors in the Markdown source files without altering the project's established voice, tone, or style.

## Functional Requirements
1.  **Configuration Management:**
    - Implement a reusable configuration utility to read settings from a git-ignored `config.ini` file.
    - Store the OpenRouter API key in `config.ini`.
2.  **AI Proofreading Script (`maintenance/proofread_content.py`):**
    - Iterate through all `.md` files in the `source/` directory (excluding drafts starting with `X` or hidden files).
    - Use the OpenRouter API with the `xiaomi/mimo-v2-flash:free` model.
    - **Prompt Constraints:**
        - Identify serious spelling and grammar mistakes only.
        - Strictly maintain the existing tone, style, and vocabulary.
        - **Include audio transcripts** (text inside `%%` blocks) in the proofreading process.
        - Ignore Pāḷi quotes (blockquotes or specific technical sections).
        - Verify spelling of Pāḷi terms when used within English prose.
3.  **Reporting System:**
    - Generate a single consolidated report at `maintenance/proofread_report.txt`.
    - **Format:**
        ```markdown
        # <filename.md>
        x <original text fragment>
        + <suggested correction>

        x <another original fragment>
        + <another suggestion>
        ```
    - Use a blank line between individual suggestion pairs.

## Non-Functional Requirements
- **Safety Policy:** The script MUST NOT modify any source files in the `source/` directory. It is a suggestion-only tool.
- **Dependency Management:** Use `uv` to manage the necessary Python SDKs (Use the `openrouter` Python SDK).
- **Efficiency:** Process files in a way that respects API rate limits and provides progress feedback.

## Acceptance Criteria
- A reusable config utility is functional.
- The `proofread_content.py` script successfully connects to OpenRouter and processes a sample file (including its transcript).
- The generated `proofread_report.txt` follows the specified format exactly.
- No source files are modified during execution.
- All new dependencies are tracked via `uv`.

## Out of Scope
- Automatic application of suggestions to source files.
