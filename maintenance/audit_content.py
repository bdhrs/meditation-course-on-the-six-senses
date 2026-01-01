import sys
import re
from pathlib import Path

# Configuration
SOURCE_DIR = Path("source")
REQUIRED_SECTIONS = [
    "Q&A",
]  # References checked separately based on content


def check_pali_formatting(content: str) -> list[str]:
    """
    Checks for unformatted Pāḷi terms in the content.
    Terms should be italicized (*Term*) or linked ([[Term]]).
    Ignores headers.
    """
    # Removed: Dhamma, Sutta, Pāḷi (per user request)
    pali_terms = [
        "Dukkha",
        "Anicca",
        "Anatta",
        "Vedanā",
        "Saṅkhāra",
        "Nibbāna",
        "Kamma",
        "Samādhi",
        "Vipassanā",
        "Mettā",
    ]
    errors = []
    lines = content.split("\n")

    for i, line in enumerate(lines):
        # Skip headers
        if line.strip().startswith("#"):
            continue

        for term in pali_terms:
            # Find all instances of the term
            # We use \b to ensure whole word matching
            pattern = rf"\b{term}\b"
            for match in re.finditer(pattern, line):
                start, end = match.span()

                # Check formatting context
                prefix = line[start - 1] if start > 0 else ""
                suffix = line[end] if end < len(line) else ""

                is_italic = prefix in ("*", "_") and suffix == prefix
                is_linked = prefix in ("[", "|") and suffix == "]"

                if not (is_italic or is_linked):
                    errors.append(f"Line {i + 1}: Unformatted Pāḷi term '{term}'")

    return errors


def check_mp3_and_transcripts(content: str, filename: str) -> list[str]:
    errors = []
    # Pattern for obsidian style mp3 links
    mp3_pattern = r"!\[\[(.*?\.mp3)\]\]"
    has_mp3 = bool(re.search(mp3_pattern, content))
    has_transcript = "%%" in content

    # Rule: If MP3 exists, Transcript MUST exist
    if has_mp3 and not has_transcript:
        errors.append(f"MP3 present but Transcript (%%...%%) missing in {filename}")

    # Rule: If Transcript exists, MP3 SHOULD exist (implied strictly 1:1)
    if has_transcript and not has_mp3:
        errors.append(f"Transcript present but MP3 link missing in {filename}")

    # Verify MP3 file existence if link is present
    if has_mp3:
        matches = re.finditer(mp3_pattern, content)
        for match in matches:
            mp3_filename = match.group(1)
            locations = [
                SOURCE_DIR / mp3_filename,
                SOURCE_DIR / "assets" / mp3_filename,
                SOURCE_DIR / "assets" / "audio" / mp3_filename,
                Path("waveform_project") / "Exported" / mp3_filename,
            ]
            if not any(loc.exists() for loc in locations):
                errors.append(
                    f"Missing MP3 file: {mp3_filename} referenced in {filename}"
                )

    return errors


def check_sections(content: str, filename: str) -> list[str]:
    errors = []

    # Exclude Section 9 and top-level sections (e.g., 1. The Six Senses)
    # Only check subsections like 1.2
    is_subsection = re.match(r"^\d+\.\d+\.", filename)
    is_section_9 = filename.startswith("9")

    if not is_subsection or is_section_9:
        return errors

    # Check for Headers
    for section in REQUIRED_SECTIONS:
        if not re.search(rf"^##.*{section}", content, re.MULTILINE):
            errors.append(f"Missing Section '{section}' in {filename}")

    # Check for References ONLY if sutta quotes exist
    # Pattern: "-- *" (dash dash space italics)
    has_sutta_quote = re.search(r"--\s+\*", content)
    if has_sutta_quote:
        if not (
            re.search(r"^##.*References", content, re.MULTILINE)
            or re.search(r"^##.*Resources", content, re.MULTILINE)
        ):
            errors.append(
                f"Missing Section 'References' (Sutta quote detected) in {filename}"
            )

    return errors


def check_broken_links(content: str, filename: str, all_files: list[Path]) -> list[str]:
    errors = []
    # [[Link]] or [[Link|Text]] or [[Link#Section]]
    wiki_link_pattern = (
        r"(?<!\!)\[\[(.*?)\]\]"  # Negative lookbehind to avoid image embeds ![[...]]
    )
    matches = re.finditer(wiki_link_pattern, content)

    all_filenames = {f.name for f in all_files}
    all_stems = {f.stem for f in all_files}

    for match in matches:
        full_link = match.group(1)
        target = full_link.split("|")[0]  # Remove alias
        target_file = target.split("#")[0]  # Remove anchor

        if not target_file:
            continue  # specific section link like [[#Section]]

        found = False
        if target_file in all_filenames:
            found = True
        elif f"{target_file}.md" in all_filenames:
            found = True
        elif target_file in all_stems:
            found = True

        if not found:
            errors.append(
                f"Broken Link in {filename}: [[{full_link}]] -> '{target_file}' not found"
            )

    return errors


def main():
    print("Starting Content Audit...")
    all_errors = {}

    md_files = sorted(list(SOURCE_DIR.glob("*.md")))

    for file in md_files:
        if file.name.startswith("X") or file.name.startswith("."):
            continue

        print(f"Checking {file.name}...")
        content = file.read_text(encoding="utf-8")
        file_errors = []

        # 1. Pali Check
        file_errors.extend(check_pali_formatting(content))

        # 2. MP3/Transcript Check
        file_errors.extend(check_mp3_and_transcripts(content, file.name))

        # 3. Section Check
        file_errors.extend(check_sections(content, file.name))

        # 4. Link Check
        file_errors.extend(check_broken_links(content, file.name, md_files))

        if file_errors:
            all_errors[file.name] = file_errors

    print("\n" + "=" * 30)
    print("AUDIT REPORT")
    print("=" * 30)

    if not all_errors:
        print("No errors found! All content matches specifications.")
    else:
        for fname, errs in all_errors.items():
            print(f"\nFILE: {fname}")
            for e in errs:
                print(f"  - {e}")

    print("\nDone.")


if __name__ == "__main__":
    main()
