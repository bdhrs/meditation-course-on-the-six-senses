"""Build the Six Senses course website using MkDocs."""

import re
import shutil
import subprocess
import zipfile
from pathlib import Path
from unidecode import unidecode
from paths import ProjectPaths
from configparser import ConfigParser
import cairosvg


def generate_pwa_icons(source_svg: str, output_dir: Path):
    """Generate PWA icons from an SVG file."""
    output_dir.mkdir(parents=True, exist_ok=True)
    for size in [192, 512]:
        png_path = output_dir / f"icon-{size}.png"
        print(f"Generating {png_path} from {source_svg}")
        cairosvg.svg2png(
            url=source_svg,
            write_to=str(png_path),
            output_width=size,
            output_height=size,
        )
    print("PWA icons generated successfully.")


def copy_files(pth: ProjectPaths):
    print("Copying files from Obsidian folder")

    # read config.ini
    config = ConfigParser()
    config.read("config.ini")
    source = config["paths"]["source_folder"]

    def ignore_xxx_files(dir, files):
        return [f for f in files if f.startswith("xxx")]

    # remove and recopy
    if pth.mkdocs_docs.exists():
        shutil.rmtree(pth.mkdocs_docs)
    # shutil.copytree(source, pth.mkdocs_docs, ignore=ignore_xxx_files)
    shutil.copytree(source, pth.mkdocs_docs)

    # make assets folder if it doesn't exist
    assets_dir = pth.mkdocs_assets_dir
    if not assets_dir.exists():
        assets_dir.mkdir()

    # copy custom css
    pth.mkdocs_custom_css_asset.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(pth.mkdocs_custom_css, pth.mkdocs_custom_css_asset)

    # copy custom js
    pth.mkdocs_custom_js_asset.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(pth.mkdocs_custom_js, pth.mkdocs_custom_js_asset)

    # copy icon to assets/images
    icon_source = "icon/six-senses.svg"
    image_destination_dir = pth.mkdocs_assets_dir / "images"
    image_destination_dir.mkdir(parents=True, exist_ok=True)
    icon_destination = image_destination_dir / "six-senses.svg"
    print(f"Copying icon from {icon_source} to {icon_destination}")
    shutil.copyfile(icon_source, icon_destination)

    # generate PWA icons
    generate_pwa_icons(source_svg=icon_source, output_dir=image_destination_dir)

    # copy manifest to docs
    manifest_source = "mkdocs_project/manifest.webmanifest"
    manifest_destination = pth.mkdocs_docs / "manifest.webmanifest"
    print(f"Copying manifest from {manifest_source} to {manifest_destination}")
    shutil.copyfile(manifest_source, manifest_destination)


def make_index(pth: ProjectPaths):
    """Make an index from file names"""

    print("Making index")

    # Ensure the docs folder exists
    docs_path = pth.mkdocs_docs
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
    pth.mkdocs_index.write_text(index_content)


def process_md_files(pth: ProjectPaths):
    """
    1. Fold the meditation instructions between %%
    2. Convert links to html
    3. Convert audio links to html players
    4. Add next link at bottom of page
    5. Compile full course .md file
    """

    print("Processing markdown files")

    full_course_text: str = ""

    md_files = list(pth.mkdocs_docs.glob("*.md"))
    md_files.sort()

    for i, md_file in enumerate(md_files):
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

        # get the next file name
        if i < len(md_files) - 1:
            next_file = md_files[i + 1]
            next_file = next_file.stem
        else:
            next_file = md_files[0]
            next_file = next_file.stem

        # add next link
        if next_file:
            md_text += f"\n\n[[{next_file}|Next]]\n\n"

        # convert links
        # this pattern captures both [[target]] and [[target|display text]] formats
        link_pattern = r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"
        md_text = re.sub(link_pattern, convert_links, md_text)

        # write modified file
        md_file.write_text(md_text)

    pth.output_markdown_file.write_text(full_course_text)


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


def make_id(id):
    id = unidecode(id)
    id = id.replace("#", "")
    id = id.replace("(", "")
    id = id.replace(")", "")
    id = id.replace(" - ", "-")
    id = id.replace(" ", "-")
    id = id.replace(".", "")
    id = id.lower()
    return id


def convert_links(match):
    # group(1) is always the target
    # group(2) is the display text (optional)
    target = match.group(1)
    display_text = match.group(2) or target

    if "#" in target:
        page, id = target.split("#", 1)
        page = page.replace(" ", "%20")
        id = make_id(id)
        href = f"{page}.html#{id}"
        return f'<a href="{href}">{display_text}</a>'
    else:
        return f'<a href="{target}.html">{display_text}</a>'


def build_mkdocs_site():
    """Build the mkdocs site"""

    print("Building mkdocs site")
    subprocess.run(["uv", "run", "mkdocs", "build"], cwd="mkdocs_project")


def zip_mkdocs(pth: ProjectPaths):
    """Zip the output folder."""

    print("Zipping mkdocs")

    # Create zip file
    with zipfile.ZipFile(pth.output_mkdocs_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for item in pth.output_mkdocs_dir.rglob("*"):
            relative_path = item.relative_to(pth.output_mkdocs_dir)
            if item.is_file():
                zipf.write(item, relative_path)
