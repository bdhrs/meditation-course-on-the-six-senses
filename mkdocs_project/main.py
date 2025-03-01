"""Build the Six Senses course website using MkDocs."""

import re
import shutil
import subprocess
import zipfile

from configparser import ConfigParser
from pathlib import Path


def copy_files():
    # read config.ini
    config = ConfigParser()
    config.read("mkdocs_project/config.ini")
    source = config["paths"]["source_folder"]
    destination = Path("mkdocs_project/docs")
    project_root = Path(__file__).parent.resolve()

    def ignore_xxx_files(dir, files):
        return [f for f in files if f.startswith("xxx")]

    # remove and recopy
    if Path(destination).exists():
        shutil.rmtree(destination)
    # shutil.copytree(source, destination, ignore=ignore_xxx_files)
    shutil.copytree(source, destination)

    # make assets folder if it doesn't exist
    assets_dir = Path(project_root / "docs/assets/")
    if not assets_dir.exists():
        assets_dir.mkdir()

    # copy custom css
    source = Path(project_root / "css/custom.css")
    destination = Path(project_root / "docs/assets/css/custom.css")
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)

    # copy custom js
    source = Path(project_root / "js/custom.js")
    destination = Path(project_root / "docs/assets/js/custom.js")
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)


def make_index():
    """Make an index from file names"""

    # Ensure the docs folder exists
    docs_path = Path("mkdocs_project/docs")
    if not docs_path.exists():
        raise FileNotFoundError(f"Docs folder not found: {docs_path}")

    # Find all markdown files
    md_files = list(docs_path.glob("*.md"))
    md_files.sort()

    # Prepare the index content
    index_content = "# Contents\n\n"

    # Process each markdown file
    for md_file in md_files:
        # Skip the index file itself
        if md_file.stem.lower() == "index":
            continue

        title = md_file.stem
        relative_path = md_file.name
        index_content += f"- [{title}]({relative_path})\n\n"

    # Write the index file
    index_path = docs_path / "index.md"
    index_path.write_text(index_content)


def process_md_files():
    """
    1. Fold the meditation instructions between %%
    2. Convert links to html
    3. Convert audio links to html players
    4. Compile full course .md file
    """

    full_course_path = Path(
        "output/Meditation Course on the Six Senses.md"
    )
    full_course_text: str = ""

    docs_path = Path("mkdocs_project/docs")
    md_files = list(docs_path.glob("*.md"))
    md_files.sort()

    for md_file in md_files:
        md_text = md_file.read_text()

        # compile full course text
        full_course_text += f"# {md_file.stem}\n\n"
        full_course_text += f"{md_text}\n\n"

        # convert meditation instructions into summary
        pattern = r"%%(.*?)%%"
        md_text = re.sub(
            pattern, convert_meditation_instruction, md_text, flags=re.DOTALL
        )

        # convert audio links
        audio_link_pattern = r"!\[\[(.*?)\]\]"
        md_text = re.sub(audio_link_pattern, convert_audio_link, md_text)

        # convert links
        # this pattern captures both [[target]] and [[target|display text]] formats
        link_pattern = r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"
        md_text = re.sub(link_pattern, convert_links, md_text)

        # write modified file
        md_file.write_text(md_text)

    full_course_path.write_text(full_course_text)


def convert_audio_link(match):
    audio_file_name = match.group(1)
    audio_player = f"""
<audio controls style="width: 100%; max-width: 600px;">
    <source src="assets/audio/{audio_file_name}" type="audio/mpeg">
</audio>
"""
    return audio_player


def convert_meditation_instruction(match):
    # Extract heading and instructions
    instructions = match.group(1)

    # Create HTML summary/details structure
    html = f"""
<details>
<summary>Transcript</summary>
{instructions}
</details>
"""
    return html


def convert_links(match):
    # group(1) is always the target
    # group(2) is the display text (optional)
    target = match.group(1)
    display_text = match.group(2) or target
    return f'<a href="{target}.html">{display_text}</a>'


def build_mkdocs_site():
    """Build the mkdocs site"""
    subprocess.run(["uv", "run", "mkdocs", "build"], cwd="mkdocs_project")


def zip_site():
    """Zip the output folder."""

    source_folder = Path("output/Meditation Course on the Six Senses")
    source_folder.mkdir(parents=True, exist_ok=True) 
    zip_filename = Path("output/Meditation Course on the Six Senses.zip")

    # Check if source folder exists
    if not source_folder.exists():
        print(f"Error: Folder {source_folder} not found.")
        return

    # Create zip file
    with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zipf:
        for item in source_folder.rglob("*"):
            # Calculate relative path to preserve folder structure
            relative_path = item.relative_to(source_folder)
            if item.is_file():
                zipf.write(item, relative_path)

    print(f"Zipped {source_folder} to {zip_filename}")


def main():
    copy_files()
    make_index()
    process_md_files()
    build_mkdocs_site()
    zip_site()


if __name__ == "__main__":
    main()
