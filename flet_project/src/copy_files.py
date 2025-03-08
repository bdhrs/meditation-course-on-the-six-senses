import shutil

from flet_project.src.helpers import ProjectData


def copy_markdown_files(g: ProjectData):
    print("Copying markdown files")
    src_dir = g.markdown_source_dir
    dest_dir = g.markdown_assets_dir

    # Delete and start again
    if dest_dir.exists():
        shutil.rmtree(dest_dir)

    # Create destination if it doesn't exist
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Copy only .md files
    for src_file in src_dir.glob("*.md"):
        dest_file = dest_dir / src_file.name
        shutil.copy2(src_file, dest_file)


def copy_audio_files(g: ProjectData):
    print("Copying mp3 files")
    src_dir = g.audio_source_dir
    dest_dir = g.audio_assets_dir

    # Delete and start again
    if dest_dir.exists():
        shutil.rmtree(dest_dir)

    # Create destination if it doesn't exist
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Copy only .mp3 files
    for src_file in src_dir.glob("*.mp3"):
        dest_file = dest_dir / src_file.name
        shutil.copy2(src_file, dest_file)
