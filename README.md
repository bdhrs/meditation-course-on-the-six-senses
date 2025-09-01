## Meditation Course on the Six Senses

Open https://bdhrs.github.io/meditation-course-on-the-six-senses/

To make the site available offline, select **Add to Home Screen** or **Install** in your browser settings.

## Build locally

Running `main.py` generates:

1. custom static website
2. mkdocs website zip
3. single page markdown file
4. single page html file 
5. epub
6. docx
7. zip of mp3's

All files can be found in the `output/` folder

### Building the Custom Website

To build the custom website locally:

```bash
uv run website_project/build.py [--mode online|offline]
```

The website will be generated in `output/Meditation Course on the Six Senses/`. Use `--mode online` for GitHub Pages deployment (external audio links) or `--mode offline` for local use (includes audio files).