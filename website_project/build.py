import shutil
import re
import json
import sys
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from markdown_it import MarkdownIt
from mdit_py_plugins.anchors import anchors_plugin
from unidecode import unidecode
import cairosvg

# Import for tests
from website_project.tests import run_tests

# --- Configuration ---
PROJECT_ROOT = Path(__file__).parent.parent
WEBSITE_ROOT = Path(__file__).parent

# Global list to store all discovered audio files
ALL_AUDIO_FILES = []

SOURCE_DIR = PROJECT_ROOT / "source"
OUTPUT_DIR = PROJECT_ROOT / "output" / "Meditation Course on the Six Senses"
STATIC_DIR = WEBSITE_ROOT / "static"
TEMPLATES_DIR = WEBSITE_ROOT / "templates"
AUDIO_SOURCE_DIR = PROJECT_ROOT / "waveform_project" / "Exported"
ICON_SOURCE = PROJECT_ROOT / "icon" / "six-senses.svg"


# --- URL Generation Functions ---
def slugify_title(title):
    """
    Convert a title into a human-readable URL slug.

    Args:
        title (str): The title to convert

    Returns:
        str: A URL-friendly slug
    """
    # Use unidecode to handle Unicode characters
    slug = unidecode(title)

    # Convert to lowercase
    slug = slug.lower()

    # Replace spaces and special characters with hyphens
    slug = re.sub(r"[^a-z0-9]+", "-", slug)

    # Remove leading and trailing hyphens
    slug = slug.strip("-")

    # Ensure we don't have empty slugs
    if not slug:
        slug = "untitled"

    return slug


# --- Main Build Functions ---


def clean_output_directory():
    """Deletes and recreates the output directory."""
    print(f"Cleaning directory: {OUTPUT_DIR}")
    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def generate_pwa_icons():
    """Generate PWA icons from the SVG file."""
    icons_dir = OUTPUT_DIR / "static" / "images"
    icons_dir.mkdir(parents=True, exist_ok=True)

    if ICON_SOURCE.exists():
        # Generate PWA icons (192px and 512px)
        for size in [192, 512]:
            png_path = icons_dir / f"icon-{size}.png"
            print(f"Generating {png_path} from {ICON_SOURCE}")
            cairosvg.svg2png(
                url=str(ICON_SOURCE),
                write_to=str(png_path),
                output_width=size,
                output_height=size,
            )

        # Generate favicon.ico
        favicon_path = OUTPUT_DIR / "favicon.ico"
        print(f"Generating {favicon_path} from {ICON_SOURCE}")
        cairosvg.svg2png(
            url=str(ICON_SOURCE),
            write_to=str(favicon_path),
            output_width=32,
            output_height=32,
        )

        print("PWA icons and favicon generated successfully.")
    else:
        print(f"Warning: Icon source not found at {ICON_SOURCE}")


def copy_static_files(mode="offline"):
    """Copies static assets. In offline mode, also copies audio."""
    print("Copying static files...")
    # Copy base static assets (CSS, JS, images)
    shutil.copytree(STATIC_DIR, OUTPUT_DIR / "static", dirs_exist_ok=True)

    # Specifically handle fonts directory to ensure only necessary files are copied
    fonts_src_dir = STATIC_DIR / "fonts"
    fonts_dest_dir = OUTPUT_DIR / "static" / "fonts"

    if fonts_src_dir.exists():
        # Clean the destination fonts directory
        if fonts_dest_dir.exists():
            shutil.rmtree(fonts_dest_dir)
        fonts_dest_dir.mkdir(parents=True, exist_ok=True)

        # Copy only the necessary font files
        for font_file in fonts_src_dir.iterdir():
            if font_file.name in [
                "inter-local.css",
                "UcC73FwrK3iLTeHuS_nVMrMxCp50SjIa1ZL7.woff2",
            ]:
                shutil.copy2(font_file, fonts_dest_dir / font_file.name)

    # Generate PWA icons
    generate_pwa_icons()

    # Copy source assets (images, etc.)
    source_assets_dir = SOURCE_DIR / "assets"
    output_assets_dir = OUTPUT_DIR / "assets"
    if source_assets_dir.exists():
        print(f"Copying source assets from {source_assets_dir} to {output_assets_dir}")
        shutil.copytree(source_assets_dir, output_assets_dir, dirs_exist_ok=True)

    # In offline mode, copy audio files
    if mode == "offline":
        audio_dest_dir = OUTPUT_DIR / "static" / "audio"
        print(f"Copying audio files to {audio_dest_dir}")
        if AUDIO_SOURCE_DIR.exists():
            shutil.copytree(AUDIO_SOURCE_DIR, audio_dest_dir, dirs_exist_ok=True)
        else:
            print(f"Warning: Audio source directory not found at {AUDIO_SOURCE_DIR}")
    print("Static files copied.")


def render_pages(mode="offline"):
    """Processes markdown files and renders them into HTML pages."""
    print("Rendering pages...")
    md = MarkdownIt()
    # Enable table support
    md.enable("table")
    # Use a custom slugify function that matches our make_id function
    md.use(anchors_plugin, min_level=1, max_level=6, slug_func=make_id)
    env = Environment(loader=FileSystemLoader(TEMPLATES_DIR))
    page_template = env.get_template("page.html")

    if not SOURCE_DIR.exists():
        print(f"Error: Source directory not found at {SOURCE_DIR}")
        return

    md_files = sorted(list(SOURCE_DIR.glob("*.md")))

    # Create a list of page dictionaries for navigation
    pages_for_nav = []
    # Add the title page as the first item in navigation
    pages_for_nav.append({"title": "Title Page", "path": "index.html"})
    for md_file in md_files:
        if not md_file.name.startswith(("X", ".")):
            slug = slugify_title(md_file.stem)
            pages_for_nav.append({"title": md_file.stem, "path": f"{slug}.html"})

    # Generate the title page dynamically
    print(" - Generating title page")
    # Use the special title page template
    title_page_template = env.get_template("title-page.html")

    # Determine previous and next pages for navigation (title page has no previous page)
    next_page = pages_for_nav[1] if len(pages_for_nav) > 1 else None

    output_html = title_page_template.render(
        title="Title Page",
        all_pages=pages_for_nav,  # For the left sidebar
        prev_page=None,  # For the footer
        next_page=next_page,  # For the footer
    )

    output_filename = OUTPUT_DIR / "index.html"
    output_filename.write_text(output_html, encoding="utf-8")

    # Process and render individual pages
    for i, md_file in enumerate(md_files):
        if md_file.name.startswith(("X", ".")):
            continue

        # Determine previous and next pages for navigation
        # This logic needs to be aware of the filtered list `pages_for_nav`
        # Title page is at index 0, so we add 1 to the index to account for it
        current_page_index = next(
            (
                j
                for j, page in enumerate(pages_for_nav)
                if page["title"] == md_file.stem
            ),
            None,
        )
        prev_page = (
            pages_for_nav[current_page_index - 1]
            if current_page_index is not None and current_page_index > 0
            else None
        )
        next_page = (
            pages_for_nav[current_page_index + 1]
            if current_page_index is not None
            and current_page_index < len(pages_for_nav) - 1
            else None
        )

        print(f"  - Processing {md_file.name}")
        raw_text = md_file.read_text(encoding="utf-8")

        processed_text = process_markdown_content(raw_text, mode)

        html_content = md.render(processed_text)
        title = md_file.stem
        slug = slugify_title(title)

        output_html = page_template.render(
            title=title,
            content=html_content,
            all_pages=pages_for_nav,  # For the left sidebar
            prev_page=prev_page,  # For the footer
            next_page=next_page,  # For the footer
        )

        output_filename = OUTPUT_DIR / f"{slug}.html"
        output_filename.write_text(output_html, encoding="utf-8")

    # Generate the table of contents page (optional)
    print("Generating table of contents page...")
    index_template = env.get_template("index.html")
    index_html = index_template.render(pages=pages_for_nav, title="Table of Contents")
    (OUTPUT_DIR / "contents.html").write_text(index_html, encoding="utf-8")

    # Generate the 404 error page
    print("Generating 404 error page...")
    error_template = env.get_template("404.html")
    error_html = error_template.render(
        title="Page Not Found",
        all_pages=pages_for_nav,  # For the left sidebar
        prev_page=None,  # For the footer
        next_page=None,  # For the footer
    )
    (OUTPUT_DIR / "404.html").write_text(error_html, encoding="utf-8")

    # Create a simplified 404 page for the root directory (for GitHub Pages)
    root_404_html = """<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Page Not Found | Six Senses</title>
    <link rel="icon" type="image/x-icon" href="favicon.ico" />
    <link rel="stylesheet" href="static/css/style.css" />
    <link rel="manifest" href="manifest.webmanifest" />
    <script>
      if ("serviceWorker" in navigator) {
        window.addEventListener("load", () => {
          navigator.serviceWorker.register("./sw.js", { scope: "./" });
        });
      }
    </script>
    <link rel="stylesheet" href="static/fonts/inter-local.css" />
  </head>
  <body>
    <header id="main-header">
      <div class="header-content">
        <img
          src="static/images/six-senses.svg"
          alt="Six Senses Logo"
          class="logo"
        />
        <span class="course-title">Meditation Course on the Six Senses</span>
      </div>
    </header>

    <div class="page-container">
      <div class="content-wrapper">
        <div class="center-pane-wrapper">
          <main class="main-content">
            <div class="error-page">
              <h1>404 - Page Not Found</h1>
              <p>Sorry, the page you're looking for has probably moved.</p>
              <p><a href="./">Return to the Title Page</a></p>
            </div>
          </main>
        </div>
      </div>
    </div>

    <script src="static/js/main.js"></script>
  </body>
</html>"""
    (OUTPUT_DIR.parent / "404.html").write_text(root_404_html, encoding="utf-8")

    print("Page rendering complete.")


def generate_pwa_assets(mode="offline"):
    """Generates the manifest and service worker for PWA functionality."""
    print("Generating PWA assets...")

    # 1. Create the manifest.webmanifest
    manifest = {
        "name": "Meditation Course on the Six Senses",
        "short_name": "Six Senses",
        "start_url": ".",
        "display": "standalone",
        "background_color": "#ffffff",
        "theme_color": "#002b60",
        "description": "A meditation course on the six senses.",
        "icons": [
            {
                "src": "static/images/icon-192.png",
                "sizes": "192x192",
                "type": "image/png",
            },
            {
                "src": "static/images/icon-512.png",
                "sizes": "512x512",
                "type": "image/png",
            },
        ],
    }
    (OUTPUT_DIR / "manifest.webmanifest").write_text(json.dumps(manifest, indent=2))

    # 2. Generate the service worker
    # Only cache specific file types to avoid issues with browser extensions
    files_to_cache = []
    for f in OUTPUT_DIR.rglob("*"):
        if f.is_file():
            relative_path = str(f.relative_to(OUTPUT_DIR))
            # Include common web assets
            if f.suffix.lower() in [
                ".html",
                ".css",
                ".js",
                ".png",
                ".jpg",
                ".jpeg",
                ".gif",
                ".svg",
                ".webmanifest",
            ]:
                files_to_cache.append(relative_path)
            # Include audio files only in offline mode
            elif mode == "offline" and f.suffix.lower() in [
                ".mp3",
                ".wav",
                ".ogg",
                ".m4a",
                ".aac",
                ".flac",
            ]:
                files_to_cache.append(relative_path)

    # Ensure index.html and root path are always cached
    if "index.html" not in files_to_cache:
        files_to_cache.append("index.html")

    # Remove duplicates while preserving order
    seen = set()
    unique_files = []
    for file in files_to_cache:
        if file not in seen:
            seen.add(file)
            unique_files.append(file)

    # Ensure we have the essential entries without duplicates
    essential_files = ["index.html"]
    for file in essential_files:
        if file not in unique_files:
            unique_files.append(file)

    sw_template_path = TEMPLATES_DIR / "sw.js.jinja"
    if not sw_template_path.exists():
        print("Service worker template not found. Skipping PWA generation.")
        return

    env = Environment(loader=FileSystemLoader(TEMPLATES_DIR))
    sw_template = env.get_template("sw.js.jinja")
    sw_content = sw_template.render(files_to_cache=unique_files)
    (OUTPUT_DIR / "sw.js").write_text(sw_content)

    print("PWA assets generated.")


# --- Content Processing Functions ---


def process_markdown_content(text, mode):
    """Applies all custom processing to the markdown content."""
    text = convert_meditation_instructions(text)
    text = convert_audio_links(text, mode)
    text = convert_image_links(text)
    text = convert_wiki_links(text)
    text = convert_sutta_references(text)
    return text


def convert_meditation_instructions(text):
    pattern = r"%%(.*?)%%"
    return re.sub(
        pattern,
        lambda m: f"<details class='transcript'><summary>Transcript</summary>{m.group(1)}</details>",
        text,
        flags=re.DOTALL,
    )


def convert_audio_links(text, mode):
    def replace_audio(match):
        audio_file = match.group(1)
        # Add the audio file to the global list for offline mode
        global ALL_AUDIO_FILES
        filename_only = Path(audio_file).name
        if filename_only not in ALL_AUDIO_FILES:
            ALL_AUDIO_FILES.append(filename_only)

        if mode == "online":
            base_url = "https://github.com/bdhrs/meditation-course-on-the-six-senses/releases/download/audio-assets/"
            # Use exact filename as-is without modification
            src = f"{base_url}{filename_only}"
        else:
            # Use exact filename as-is without modification
            src = f"static/audio/{filename_only}"
        return f'<audio controls style="width: 100%;"><source src="{src}" type="audio/mpeg"></audio>'

    # Using raw string for regex pattern
    audio_pattern = r"!\[\[(.*?\.mp3)\]\]"
    return re.sub(audio_pattern, replace_audio, text)


def convert_image_links(text):
    def replace_image(match):
        image_file = match.group(1)
        # Images are always served locally from the assets folder
        src = f"assets/images/{image_file}"
        return f"![]({src})"

    # Using raw string for regex pattern
    image_pattern = r"!\[\[(.*?\.(?:png|jpg|jpeg|gif|svg))\]\]"
    return re.sub(image_pattern, replace_image, text, flags=re.IGNORECASE)


def convert_wiki_links(text):
    def replace_link(match):
        target = match.group(1)
        display_text = match.group(2) or target

        if "#" in target:
            page, heading_id = target.split("#", 1)
            href = f"{slugify_title(page)}.html#{make_id(heading_id)}"
        else:
            href = f"{slugify_title(target)}.html"
        return f'<a href="{href}">{display_text}</a>'

    # Using raw string for regex pattern
    link_pattern = r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"
    return re.sub(link_pattern, replace_link, text)


def convert_sutta_references(text):
    """Wraps sutta references in a span for styling and removes the '--'."""
    # This pattern finds '--' and captures the italicized text part.
    pattern = r"--\s+(\*.*\*)"
    return re.sub(pattern, r"<br><span class='sutta-reference'>\1</span>", text)


def make_id(text):
    """Converts a string into a URL-friendly ID."""
    # Use unidecode to convert Unicode to ASCII, matching what the browser will do
    from unidecode import unidecode

    text = unidecode(text)
    # Use the same slugify logic as the markdown-it anchors plugin
    return re.sub(r"[^\w\u4e00-\u9fff\- ]", "", text.strip().lower().replace(" ", "-"))


def generate_audio_files_list():
    """Generates a JSON file containing all audio files needed for offline mode."""
    global ALL_AUDIO_FILES
    if ALL_AUDIO_FILES:
        # Sort and deduplicate the list
        audio_files = sorted(list(set(ALL_AUDIO_FILES)))
        audio_list_path = OUTPUT_DIR / "audio-files.json"
        with open(audio_list_path, "w", encoding="utf-8") as f:
            json.dump(audio_files, f, indent=2)
        print(f"Found {len(audio_files)} audio files")
        print(f"Generated audio files list: {audio_list_path}")

    else:
        print("No audio files found in markdown content.")


# --- Main Execution ---


def main():
    """Main function to build the static website."""
    import argparse

    parser = argparse.ArgumentParser(description="Build the Six Senses website.")
    parser.add_argument(
        "--mode",
        choices=["online", "offline"],
        default="offline",
        help="Build mode: 'online' for GitHub Pages with external audio, 'offline' for local use with included audio.",
    )
    args = parser.parse_args()
    mode = args.mode

    print(f"--- Starting website build (mode: {mode}) ---")

    # Run tests first - stop build if tests fail
    print("\n--- Running tests ---")

    if not run_tests(SOURCE_DIR):
        print("\n--- Tests failed! Stopping build process. ---")
        sys.exit(1)
    print("\n--- All tests passed! ---")

    clean_output_directory()
    copy_static_files(mode)
    render_pages(mode)
    generate_pwa_assets(mode)

    # Generate audio files list for offline mode
    generate_audio_files_list()

    print("\n--- Build process completed successfully! ---")


if __name__ == "__main__":
    main()
