import argparse
import sys
from website_project.build import build_website
from build_utils import generate_ebook_source, zip_website, zip_mp3s
from markdown_to_html import convert_html_to_ebooks
from markdown_to_html import convert_markdown_to_html
from paths import ProjectPaths


def export_course(mode):
    pth = ProjectPaths()

    # 1. Build the website (HTML, CSS, JS, Assets)
    print("\n=== Building Website ===")
    if not build_website(mode):
        print("Website build failed.")
        sys.exit(1)

    # 2. Generate source markdown for ebooks
    print("\n=== Generating Ebook Source ===")
    generate_ebook_source(pth)

    # 3. Convert markdown to HTML for ebooks
    print("\n=== Converting Markdown to HTML for Ebooks ===")
    convert_markdown_to_html(pth)

    # 4. Convert HTML to EPUB/DOCX
    print("\n=== Converting HTML to Ebooks ===")
    convert_html_to_ebooks(pth)

    # 5. Zip everything
    print("\n=== Zipping Outputs ===")
    zip_website(pth)
    zip_mp3s(pth)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build the Six Senses course.")
    parser.add_argument(
        "--mode",
        choices=["online", "offline"],
        default="offline",
        help="Build mode: 'online' for github releases, 'offline' for local.",
    )
    args = parser.parse_args()

    export_course(args.mode)
