from pathlib import Path
from dataclasses import dataclass


@dataclass
class ProjectPaths:
    project_name = "Meditation Course on the Six Senses"
    mkdocs_root = Path("mkdocs_project")
    mkdocs_docs = Path(mkdocs_root / "docs")
    mkdocs_assets_dir = Path(mkdocs_root / "docs/assets/")
    mkdocs_custom_css = Path(mkdocs_root / "css/custom.css")
    mkdocs_custom_css_asset = Path(mkdocs_root / "docs/assets/css/custom.css")
    mkdocs_custom_js = Path(mkdocs_root / "js/custom.js")
    mkdocs_custom_js_asset = Path(mkdocs_root / "docs/assets/js/custom.js")
    mkdocs_index = Path(mkdocs_docs / "index.md")

    output_dir = Path("output")

    output_mkdocs_dir = Path(output_dir / project_name)
    output_mkdocs_zip = Path(output_dir / f"{project_name}.zip")
    output_mkdocs_audio_assets_dir = Path(output_dir / project_name / "assets/audio")

    output_markdown_file = Path(output_dir / f"{project_name}.md")
    output_html_file = Path(output_dir / f"{project_name}.html")
    output_epub_file = Path(output_dir / f"{project_name}.epub")
    output_docx_file = Path(output_dir / f"{project_name}.docx")
    output_mp3_zip = Path(output_dir / "mp3s.zip")

    def __post_init__(self):
        self.output_dir.mkdir(parents=True, exist_ok=True)
