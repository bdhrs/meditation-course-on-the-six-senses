## Meditation Course on the Six Senses

Open https://bdhrs.github.io/meditation-course-on-the-six-senses/

To make the site available offline, select **Add to Home Screen** or **Install** in your browser settings.

## Build locally

The project uses a custom build system orchestrated by `main.py`.

### Prerequisites

- [uv](https://github.com/astral-sh/uv) installed.
- [Flutter](https://flutter.dev/docs/get-started/install) installed (for building mobile and desktop apps).
- **For Linux builds**: `appimagetool` installed. Download and install:

```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool
```

### Building the Project

To build the entire project (website, ebooks, zips), run:

```bash
uv run main.py --mode offline
```

Use `--mode online` for GitHub Pages deployment (external audio links) or `--mode offline` for local use (includes audio files).

### Outputs

All generated files can be found in the `output/` folder:

1.  **Meditation Course on the Six Senses/**: The complete static website.
2.  **Meditation Course on the Six Senses.zip**: Zipped version of the website.
3.  **Meditation Course on the Six Senses.epub**: Ebook version.
4.  **Meditation Course on the Six Senses.docx**: Word document version.
5.  **Meditation Course on the Six Senses.md**: Single-page markdown source.
6.  **mp3s.zip**: Archive of all audio files.
7.  **apps/**: Flutter applications:
    - **6 Senses.apk**: Android app
    - **6 Senses.appimage**: Linux app

### Development

The website build logic is located in `website_project/build.py`. You can run it independently if you only want to rebuild the website:

```bash
uv run website_project/build.py --mode offline
```