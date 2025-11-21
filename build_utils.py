import re
import zipfile
import shutil
from pathlib import Path
from paths import ProjectPaths

def generate_ebook_source(pth: ProjectPaths):
    """
    Generates a single markdown file from all source markdown files for ebook generation.
    """
    print("Generating ebook source markdown...")
    
    source_dir = Path("source")
    full_course_text = ""
    
    md_files = sorted(list(source_dir.glob("*.md")))
    
    for md_file in md_files:
        if md_file.name.startswith(("X", ".")):
            continue
            
        md_text = md_file.read_text(encoding="utf-8")
        
        # Add title
        full_course_text += f"# {md_file.stem}\n\n"
        full_course_text += f"{md_text}\n\n"

    # Apply transformations
    
    # 1. Convert meditation instructions
    # %%...%% -> <details>...
    pattern = r"%%(.*?)%%"
    full_course_text = re.sub(
        pattern, 
        lambda m: f"<details><summary>Transcript</summary>{m.group(1)}</details>", 
        full_course_text, 
        flags=re.DOTALL
    )
    
    # 2. Convert audio links
    # ![[file.mp3]] -> **Listen to: file.mp3**
    audio_pattern = r"!\[\[(.*?\.mp3)\]\]"
    full_course_text = re.sub(
        audio_pattern, 
        r"**Listen to: \1**", 
        full_course_text
    )
    
    # 3. Convert images (SVG, PNG, JPG, etc.)
    # ![[file.ext]] -> ![file.ext](ProjectName/assets/images/file.ext)
    # We need to point to the assets folder inside the project output directory
    # And we should URL encode the path parts to be safe for HTML/Pandoc
    import urllib.parse
    project_path_encoded = urllib.parse.quote(pth.project_name)
    assets_path = f"{project_path_encoded}/assets/images"
    
    image_pattern = r"!\[\[(.*?\.(\w+))\]\]"
    full_course_text = re.sub(
        image_pattern, 
        rf"![\1]({assets_path}/\1)", 
        full_course_text
    )
    
    # 4. Convert wiki links
    # [[target]] or [[target|display]] -> [display](target)
    # Note: For ebook, we might want internal links or just text. 
    # The previous logic in make_mkdocs.py converted them to HTML links.
    # markdown_to_html.py also handles links. 
    # Let's leave them as wiki links here if markdown_to_html.py handles them, 
    # OR convert them to standard markdown links.
    # Looking at markdown_to_html.py, it has `convert_links` which handles `[[...]]`.
    # So we can leave them as is, OR we can do a preliminary pass.
    # However, `markdown_to_html.py` reads `pth.output_markdown_file`.
    # So we just write the concatenated text there.
    
    pth.output_markdown_file.write_text(full_course_text, encoding="utf-8")
    print(f"Ebook source written to {pth.output_markdown_file}")


def zip_website(pth: ProjectPaths):
    """Zips the output folder."""
    print(f"Zipping website to {pth.output_site_zip}")
    
    if not pth.output_site_dir.exists():
        print(f"Warning: Output directory {pth.output_site_dir} does not exist.")
        return

    with zipfile.ZipFile(pth.output_site_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for item in pth.output_site_dir.rglob("*"):
            relative_path = item.relative_to(pth.output_site_dir)
            if item.is_file():
                zipf.write(item, relative_path)
    print("Website zipped.")


def zip_mp3s(pth: ProjectPaths):
    """Zips the mp3 files."""
    print(f"Zipping mp3s to {pth.output_mp3_zip}")
    
    # The new build system puts audio in static/audio
    audio_dir = pth.output_site_dir / "static" / "audio"
    
    if not audio_dir.exists():
        print(f"Warning: Audio directory {audio_dir} does not exist.")
        return

    with zipfile.ZipFile(pth.output_mp3_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for file in audio_dir.glob("*.mp3"):
            zipf.write(file, file.name)
            
    print("MP3s zipped.")
