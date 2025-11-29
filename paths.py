from pathlib import Path
from dataclasses import dataclass


@dataclass
class ProjectPaths:
    project_name = "Meditation Course on the Six Senses"
    
    # Output directories
    output_dir = Path("output")
    output_site_dir = Path(output_dir / project_name)
    output_site_zip = Path(output_dir / f"{project_name}.zip")
    
    # Ebook and other outputs
    output_markdown_file = Path(output_dir / f"{project_name}.md")
    output_html_file = Path(output_dir / f"{project_name}.html")
    output_epub_file = Path(output_dir / f"{project_name}.epub")
    output_docx_file = Path(output_dir / f"{project_name}.docx")
    output_mp3_zip = Path(output_dir / "mp3s.zip")
    
    flutter_project_path = Path("flutter_project")

    # Legacy / MkDocs paths (to be removed later or kept for reference if needed)
    mkdocs_root = Path("mkdocs_project")
    mkdocs_docs = Path(mkdocs_root / "docs")
    mkdocs_index = Path(mkdocs_docs / "index.md")

    def __post_init__(self):
        self.output_dir.mkdir(parents=True, exist_ok=True)
