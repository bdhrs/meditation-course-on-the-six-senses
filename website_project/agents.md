# Website Project - Six Senses Meditation Course

# Instructions for ai agents.

## USE UV
- Add dependencies using `uv add` from the root directory.
- Build using `uv run website_project/build.py` from the root dir.

## GENERAL
- Do not run a python server, it is already running.
- Only make the requested changes. You make make suggestions, but no changes to the code outside the scope of the requested changes.
- If any instruction is ambiguous, clarify before continuing.
- DO NOT use SearchText tool, it fails consistently. Just open the file itself and read it. 
- AlWAYS read the whole file, DO NOT read files piece by piece.
- Follow all instructions explicitly.

## UPON COMPLETION
- After the user expressed satisfaction with the changes, never before that:
    1. update this document
    2. provide a github commit message, simple and lowercase. e.g. fix: updated fonts in file abc.html
    3. DO NOT commit!

## Project Overview
This project builds a static website for the "Meditation Course on the Six Senses". The website is generated from markdown source files and includes features like:
- Dark/light mode toggle with SVG icons
- Online/offline mode toggle with SVG icons
- Progressive Web App (PWA) support
- Responsive design
- Table of contents generation
- Audio player integration
- Interactive hover effects on toggle buttons
- Proper logo visibility in both light and dark modes
- Enhanced header and footer with distinct styling and shadows
- Toggle buttons that stay side-by-side on narrow screens
- Custom styled tooltips that match the theme colors and appear below icons
- Custom scrollbars throughout the site that match the theme (dark background with green thumb)
- Fixed console errors (missing favicon, missing PWA icons, service worker duplicates)
- Human-readable URLs generated from page titles
- Fixed tooltip visibility issues by allowing overflow in header
- Fixed inverted tooltip colors in light/dark modes
- Fixed tooltip positioning to stay on screen by anchoring to the right
- Global font set to Inter for better readability and available offline
- **Fixed reference links to correctly jump to specific headings on target pages**
- **Creative Commons logo now available offline in assets folder**

## Tech Stack
- **Python** - Core language for build scripts
- **Jinja2** - Templating engine for HTML generation
- **Markdown-it-py** - Markdown to HTML conversion
- **Unidecode** - Unicode text processing
- **CairoSVG** - SVG to PNG/ICO conversion for icons
- **CSS3** - Styling with CSS variables for theming
- **JavaScript** - Client-side interactivity
- **HTML5** - Semantic markup
- **SVG** - Vector icons for crisp display at any resolution

## Key Files and Directories

### Build System
- `uv run website_project/build.py` - Main build script that orchestrates the entire process, including URL generation
- `pyproject.toml` - Project dependencies and metadata (in root directory)

### Source Content
- `../source/` - Directory containing all markdown content files
- `../source/assets/` - Directory containing image and audio assets referenced in content

### Templates
- `templates/base.html` - Base template with header, layout structure
- `templates/page.html` - Template for individual content pages
- `templates/index.html` - Template for the table of contents page
- `templates/sw.js.jinja` - Service worker template for PWA functionality

### Static Assets
- `static/css/style.css` - Main stylesheet with light/dark themes
- `static/js/main.js` - Client-side JavaScript for interactivity
- `static/images/` - Image assets including logo
- `../waveform_project/Exported/` - Audio files (in offline mode)
- `../icon/six-senses.svg` - Source SVG for favicon and PWA icons

### Reference Materials
- `ref_pics/` - Design reference files including `stitch1.html` which contains the original design mockup

### Output
- `output/` - Generated static website files
- `output/assets/` - Copied assets from source directory (images, etc.)

## Dependencies
All dependencies are managed with uv in the root `pyproject.toml`. Key packages include:
- `jinja2` - Templating engine (installed automatically when running the build)
- `markdown-it-py` - Markdown parser (installed automatically when running the build)
- `unidecode` - Unicode text processing
- `cairosvg` - SVG to PNG/ICO conversion
- `mdit-py-plugins` - Plugins for markdown-it-py (added to fix reference links)

## How to Use

### Install Dependencies
```bash
uv sync
```

If you encounter missing dependencies when running the build, install them with:
```bash
uv add jinja2 markdown-it-py cairosvg mdit-py-plugins
```

### Run the Build
```bash
uv run build.py
```

### Development Workflow
1. Edit markdown files in `../source/`
2. Modify templates in `templates/` as needed
3. Update styles in `static/css/style.css`
4. Enhance functionality in `static/js/main.js`
5. Run `uv run build.py` to generate the website
6. View the result in `output/index.html`

### Serve the Website Locally
After building, you can serve the website locally:
```bash
cd output
python -m http.server 8000
```
Then open `http://localhost:8000` in your browser.

## Features Implementation

### Theme Toggle
- Implemented in `static/js/main.js`
- Uses localStorage to remember user preference
- CSS in `static/css/style.css` uses variables for theme colors
- Toggle button in `templates/base.html` uses SVG icons from the reference design
- Icons switch between sun (light mode) and moon (dark mode)
- Custom tooltips show "Light/Dark Mode" positioned below the buttons

### Online/Offline Mode
- Build script supports both modes
- Audio files are included in offline mode only
- Online mode uses external URLs for audio
- Toggle button in `templates/base.html` uses SVG icons (wifi and computer)
- This is currently a visual indicator only - actual mode is determined at build time
- Custom tooltips show "Online/Offline Mode" positioned below the buttons

### Human-Readable URLs
- Implemented in `website_project/build.py`
- Added `slugify_title()` function to convert page titles to URL-friendly slugs
- Converts Unicode characters to ASCII equivalents using `unidecode`
- Replaces spaces and special characters with hyphens
- All internal links use the new URL format
- Wiki-style links in content are automatically converted to use human-readable URLs

### Reference Links to Specific Headings
- **Fixed issue where reference links with Unicode characters weren't jumping to the correct position**
- Updated `make_id()` function to convert Unicode to ASCII for consistent ID generation
- Configured markdown-it anchors plugin to use the same function for HTML heading IDs
- Ensured URL fragments in links match HTML heading IDs exactly
- All reference links now correctly jump to their target headings

### Interactive Elements
- Toggle buttons have hover and click effects for better user feedback
- Smooth transitions and animations for a polished experience
- Logo visibility is optimized for both light and dark modes
- Custom tooltips with theme-matching colors and modern styling
- Tooltips appear below buttons to avoid cutoff issues

### Custom Scrollbars
- Custom scrollbar styling applied throughout the entire site
- In dark mode, scrollbars have the same background as header/footer bars (#0f1c14)
- Scrollbar thumbs use the theme green color (#96c5a9 in dark mode, #366348 in light mode)
- In light mode, scrollbars use a light background with darker green thumb
- Custom styling for both WebKit browsers (Chrome, Safari) and Firefox
- Scrollbar thumbs have hover effects for better interactivity
- Rounded corners for a modern appearance
- Includes the main page scrollbar on the right-hand margin
- Applied to all scrollable areas (sidebars, main content, body)

### PWA Support
- Generates `manifest.webmanifest` for app installation
- Creates `sw.js` service worker for offline caching
- Automatically generates PWA icons (192px and 512px) from SVG source
- Generates favicon.ico from SVG source
- Fixed service worker duplicate entry issues
- Properly caches all essential files without conflicts

### Enhanced Header and Footer
- Header and footer have a distinct background color that's slightly darker than the main background
- Strong shadows separate them from the rest of the content
- Different shadow strengths for light and dark modes
- Smooth transitions when switching between themes
- Header content layout prevents premature text clipping

### Responsive Design
- CSS media queries for different screen sizes
- Sidebars collapse on mobile devices
- Flexible layout using CSS Flexbox
- Toggle buttons stay side-by-side even on narrow screens
- Appropriate sizing and spacing for all screen sizes
