import argparse
from make_mkdocs import copy_css_and_js, copy_md_files
from make_mkdocs import make_index
from make_mkdocs import build_mkdocs_site
from make_mkdocs import zip_mkdocs
from make_mkdocs import process_md_files
from markdown_to_html import convert_html_to_ebooks
from markdown_to_html import convert_markdown_to_html
from markdown_to_html import zip_mp3s
from paths import ProjectPaths


def export_course(mode):
    pth = ProjectPaths()

    # copy all relevant files
    if mode == "offline":
        print("Copying files for offline build...")
        copy_md_files(pth)
    copy_css_and_js(pth)

    # make mkdocs
    process_md_files(pth, mode)
    make_index(pth)
    build_mkdocs_site(mode)

    # make other output files
    convert_markdown_to_html(pth)
    convert_html_to_ebooks(pth)

    # zip up
    zip_mkdocs(pth)
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
