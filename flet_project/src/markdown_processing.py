import re
import unicodedata
from pathlib import Path
from collections import defaultdict

import flet as ft
from flet import ControlEvent

from flet_project.src.custom_classes import (
    HeadingOne,
    HeadingThree,
    HeadingTwo,
    Paragraph,
    Quote,
    Transcript,
    TranscriptContent,
)
from flet_project.src.project_data import ProjectData


def slugify(text: str) -> str:
    """Convert text to URL-friendly slug"""
    text = unicodedata.normalize('NFKD', text)
    text = text.encode('ascii', 'ignore').decode('ascii')
    text = re.sub(r'[^\w\s-]', '', text.lower())
    text = re.sub(r'[-\s]+', '-', text).strip('-_')
    return text


def process_markdown(
    page: ft.Page, g: ProjectData, e: ControlEvent = None, file_path=None
):
    # Track used IDs to handle duplicates
    used_ids = defaultdict(int)
    
    # Can be triggered by page load or by a button click
    # This handles page load with a file_path
    if file_path:
        file_path = file_path
        print(file_path)

    # This handles a button click
    else:
        file_path: Path = e.control.data
        print(file_path)

    with open(str(file_path), "r") as file:
        md_raw = file.read()

    # Controls list
    controls: list[ft.Control] = []
    controls.append(HeadingOne(file_path.stem))

    # Regex patterns
    audio_pattern = r"!\[\[(.+\.mp3)\]\]"
    link_pattern = r"^\d+\.\s\[\[([^|\]]+)#([^|\]]+)\|([^\]]+)\]\]"

    # Handling transcripts
    is_transcript = False
    transcript_content = []

    # Process lines
    md_lines = md_raw.split("\n")
    for md_line in md_lines:
        md_line = md_line.strip()

        # check for %% transscripts
        if md_line.startswith("%%") and not is_transcript:
            is_transcript = True
            transcript_content = []
            continue
        elif not md_line.startswith("%%") and is_transcript:
            if md_line.startswith("---"):
                transcript_content.append(ft.Divider())
                continue
            elif re.match(r"^$", md_line): # ignore blank lines
                continue
            else:
                transcript_content.append(TranscriptContent(md_line))
                continue
        elif md_line.startswith("%%") and is_transcript:
            controls.append(Transcript(transcript_content))
            is_transcript = False
            continue

        # Check for audio file link
        audio_match = re.match(audio_pattern, md_line)
        if audio_match:
            controls.append(Paragraph("player goes here"))

        # Headings
        elif re.match(r"^#\s", md_line):
            heading_text = md_line[2:]
            controls.append(HeadingOne(heading_text))
        elif re.match(r"^##\s", md_line):
            heading_text = md_line[3:]
            controls.append(HeadingTwo(heading_text))
        elif re.match(r"^###\s", md_line):
            heading_text = md_line[3:]
            controls.append(HeadingThree(heading_text))
        
        # Blank lines, blank quotes
        elif re.match(r"^$|^> *$", md_line):
            pass

        # Quotes
        elif md_line.startswith(">"):
            controls.append(Quote(md_line))

        # Normal lines
        else:
            controls.append(Paragraph(md_line))

    return ft.Column(
        controls=controls,
        expand=True,
        scroll=ft.ScrollMode.AUTO,
        spacing=50,
        tight=True,
    )
