import argparse
import sys
import subprocess
import shutil
from pathlib import Path
from website_project.build import build_website
from build_utils import generate_ebook_source, zip_website, zip_mp3s
from markdown_to_html import convert_html_to_ebooks
from markdown_to_html import convert_markdown_to_html
from paths import ProjectPaths
from flutter_project.copy_assets import copy_flutter_source_files


def _build_flutter_android(pth):
    print("\n--- Building Flutter Android app ---")
    result = subprocess.run(
        "flutter build apk --release",
        cwd=pth.flutter_project_path,
        shell=True,
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        print(f"Error Building Flutter Android app:\n{result.stderr.decode()}")
        sys.exit(1)
    else:
        print("Successfully Built Flutter Android app.")
        print(result.stdout.decode())

        # Copy APK to output/apps directory
        apk_source = (
            pth.flutter_project_path / "build/app/outputs/flutter-apk/app-release.apk"
        )
        apk_dest_dir = pth.output_dir / "apps"
        apk_dest_dir.mkdir(parents=True, exist_ok=True)
        apk_dest = apk_dest_dir / "6 Senses.apk"

        print(f"Copying APK to {apk_dest}")
        shutil.copy2(apk_source, apk_dest)
        print(f"APK copied successfully to {apk_dest}")


def _build_flutter_linux(pth):
    print("\n--- Building Flutter Linux app ---")
    result = subprocess.run(
        "flutter build linux --release",
        cwd=pth.flutter_project_path,
        shell=True,
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        print(f"Error Building Flutter Linux app:\n{result.stderr.decode()}")
        sys.exit(1)
    else:
        print("Successfully Built Flutter Linux app.")
        print(result.stdout.decode())

        # Create AppImage
        print("\n--- Creating AppImage ---")
        bundle_dir = pth.flutter_project_path / "build/linux/x64/release/bundle"
        appimage_dest_dir = pth.output_dir / "apps"
        appimage_dest_dir.mkdir(parents=True, exist_ok=True)
        appimage_dest = appimage_dest_dir / "6 Senses.appimage"

        # Remove existing AppImage if it exists
        if appimage_dest.exists():
            print(f"Removing existing AppImage at {appimage_dest}")
            appimage_dest.unlink()

        # Create AppDir structure
        appdir = Path("AppDir")
        if appdir.exists():
            shutil.rmtree(appdir)
        appdir.mkdir()

        # Copy bundle contents
        shutil.copytree(bundle_dir, appdir / "usr/bin", dirs_exist_ok=True)

        # Create desktop file
        desktop_file = appdir / "six_senses_app.desktop"
        desktop_file.write_text("""[Desktop Entry]
Name=6 Senses
Exec=six_senses_app
Icon=six_senses_app
Type=Application
Categories=Education;
""")

        # Create AppRun
        apprun = appdir / "AppRun"
        apprun.write_text("""#!/bin/bash
DIR="$(dirname "$(readlink -f "${0}")")"
exec "$DIR/usr/bin/six_senses_app" "$@"
""")
        apprun.chmod(0o755)

        # Copy icon if exists
        icon_source = pth.flutter_project_path / "assets/images/six-senses-flutter.png"
        if icon_source.exists():
            shutil.copy2(icon_source, appdir / "six_senses_app.png")

        # Build AppImage
        print("Building AppImage...")
        build_result = subprocess.run(
            f"appimagetool AppDir '{appimage_dest}'",
            shell=True,
            check=False,
            capture_output=True,
            env={**subprocess.os.environ, "ARCH": "x86_64"},
        )

        if build_result.returncode != 0:
            print(f"Error creating AppImage:\n{build_result.stderr.decode()}")
            sys.exit(1)
        else:
            print(f"AppImage created successfully at {appimage_dest}")
            # Clean up
            shutil.rmtree(appdir)
            print(result.stdout.decode())


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

    # 6. Copy Flutter assets
    print("\n=== Copying Flutter assets ===")
    copy_flutter_source_files()

    # 7. Build Flutter apps
    print("\n=== Building Flutter Apps ===")
    _build_flutter_android(pth)
    _build_flutter_linux(pth)


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
