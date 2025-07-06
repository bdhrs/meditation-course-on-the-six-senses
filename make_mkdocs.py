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


def copy_md_files(pth: ProjectPaths):
    print("Copying .md files from Obsidian folder")

    # read config.ini
    config = ConfigParser()
    config.read("config.ini")
    source = config["paths"]["source_folder"]

    def ignore_x_files(dir, files):
        return [f for f in files if f.startswith("X")]

    # remove and recopy
    if pth.mkdocs_docs.exists():
        shutil.rmtree(pth.mkdocs_docs)
    shutil.copytree(source, pth.mkdocs_docs, ignore=ignore_x_files)
    # shutil.copytree(source, pth.mkdocs_docs)


def copy_css_and_js(pth: ProjectPaths):
    print("Copying custom CSS and JS files")

    # make assets folder if it doesn't exist
    assets_dir = pth.mkdocs_assets_dir
    if not assets_dir.exists():
        assets_dir.mkdir()

    # copy custom css
    pth.mkdocs_custom_css_asset.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(pth.mkdocs_custom_css, pth.mkdocs_custom_css_asset)

    # copy custom js files
    js_source_dir = pth.mkdocs_root / "js"
    js_dest_dir = pth.mkdocs_assets_dir / "js"
    js_dest_dir.mkdir(parents=True, exist_ok=True)

    for js_file in js_source_dir.glob("*.js"):
        # Skip service worker - it gets copied to root separately
        print(f"Copying {js_file.name} to {js_dest_dir}")
        shutil.copy(js_file, js_dest_dir)

    # copy service worker to docs root (not in assets)
    sw_source = js_source_dir / "sw.js"
    if sw_source.exists():
        sw_destination = pth.mkdocs_docs / "sw.js"
        print(f"Copying service worker from {sw_source} to {sw_destination}")
        shutil.copyfile(sw_source, sw_destination)

    # copy icon to assets/images
    icon_source = "icon/six-senses.svg"
    image_destination_dir = pth.mkdocs_assets_dir / "images"
    image_destination_dir.mkdir(parents=True, exist_ok=True)
    icon_destination = image_destination_dir / "six-senses.svg"
    print(f"Copying icon from {icon_source} to {icon_destination}")
    shutil.copyfile(icon_source, icon_destination)

    # generate PWA icons
    generate_pwa_icons(source_svg=icon_source, output_dir=image_destination_dir)

    # copy manifest and offline.html to docs
    manifest_source = "mkdocs_project/manifest.webmanifest"
    manifest_destination = pth.mkdocs_docs / "manifest.webmanifest"
    print(f"Copying manifest from {manifest_source} to {manifest_destination}")
    shutil.copyfile(manifest_source, manifest_destination)

    offline_source = "mkdocs_project/html/offline.html"
    offline_destination = pth.mkdocs_docs / "offline.html"
    print(f"Copying offline page from {offline_source} to {offline_destination}")
    shutil.copyfile(offline_source, offline_destination)


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

    # Add PWA meta tags to all HTML files
    add_pwa_meta_tags()


def add_pwa_meta_tags():
    """Add PWA meta tags to all HTML files in the output directory"""

    print("Adding PWA meta tags to HTML files")

    pth = ProjectPaths()
    output_dir = pth.output_mkdocs_dir

    # PWA meta tags to inject
    pwa_meta_tags = """
    <!-- PWA Manifest -->
    <link rel="manifest" href="manifest.webmanifest">

    <!-- PWA Meta Tags -->
    <meta name="theme-color" content="#002b60">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-title" content="Six Senses">

    <!-- Apple Touch Icons -->
    <link rel="apple-touch-icon" href="assets/images/icon-192.png">
    <link rel="apple-touch-icon" sizes="192x192" href="assets/images/icon-192.png">
    <link rel="apple-touch-icon" sizes="512x512" href="assets/images/icon-512.png">

    <!-- Register service worker -->
    <script>
      if ('serviceWorker' in navigator) {
        window.addEventListener('load', function() {
          navigator.serviceWorker.register('/meditation-course-on-the-six-senses/sw.js', { scope: '/meditation-course-on-the-six-senses/' });
        });
      }
    </script>
    """

    # Process all HTML files
    html_files = list(output_dir.rglob("*.html"))
    for html_file in html_files:
        try:
            content = html_file.read_text(encoding="utf-8")

            # Insert PWA meta tags before </head>
            if "</head>" in content:
                content = content.replace("</head>", f"{pwa_meta_tags}\\n  </head>")
                html_file.write_text(content, encoding="utf-8")
                print(f"Added PWA meta tags to {html_file.name}")
        except Exception as e:
            print(f"Error processing {html_file}: {e}")

    # Generate files-to-cache.json
    files_to_cache = [str(f.relative_to(output_dir)) for f in html_files]
    css_files = [
        str(f.relative_to(output_dir))
        for f in output_dir.rglob("assets/stylesheets/*.css")
    ]
    js_files = [
        str(f.relative_to(output_dir))
        for f in output_dir.rglob("assets/javascripts/*.js")
    ]
    image_files = [
        str(f.relative_to(output_dir)) for f in output_dir.rglob("assets/images/*")
    ]
    files_to_cache.extend(css_files)
    files_to_cache.extend(js_files)
    files_to_cache.extend(image_files)

    import json

    with open(output_dir / "files-to-cache.json", "w") as f:
        json.dump(files_to_cache, f)
    print("Generated files-to-cache.json")


def zip_mkdocs(pth: ProjectPaths):
    """Zip the output folder."""

    print("Zipping mkdocs")

    # Create zip file
    with zipfile.ZipFile(pth.output_mkdocs_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for item in pth.output_mkdocs_dir.rglob("*"):
            relative_path = item.relative_to(pth.output_mkdocs_dir)
            if item.is_file():
                zipf.write(item, relative_path)


if __name__ == "__main__":
    pth = ProjectPaths()
    copy_md_files(pth)
    process_md_files(pth)
    make_index(pth)
    build_mkdocs_site()
    zip_mkdocs(pth)
    print("Done")
