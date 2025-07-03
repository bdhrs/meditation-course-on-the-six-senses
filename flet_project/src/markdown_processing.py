import re

import flet as ft

from flet_project.src.custom_classes import (
    HeadingOne,
    HeadingThree,
    HeadingTwo,
    Paragraph,
    Quote,
    Transcript,
    TranscriptContent,
)
from flet_project.src.project_data import PageData, ProjectData
from flet_project.src.navigation import NavigationHandler



def make_page_data(g: ProjectData):
    """Convert markdown files into PageData."""
    print("Converting markdown to Pagedata")
    for md_file in sorted(g.markdown_assets_dir.iterdir()):
        if re.match(r"^\d*\. ", md_file.stem):
            # These are sections headings with no content
            pass
        else:
            g.pages_list.append(md_file.stem)
            p = PageData()
            p.page_title = md_file.stem
            p.page_path = md_file

            p = process_markdown(p, g)
            g.page_data[p.page_title] = p


def process_markdown(p: PageData, g: ProjectData):
    """Process markdown content into page controls"""

    with open(str(p.page_path), "r") as file:
        md_raw = file.read()

    # Controls list
    controls: list[ft.Control] = []
    controls.append(HeadingOne(p.page_path.stem))

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

        # check for %% transcripts
        if md_line.startswith("%%") and not is_transcript:
            is_transcript = True
            transcript_content = []
            continue
        elif not md_line.startswith("%%") and is_transcript:
            if md_line.startswith("---"):
                transcript_content.append(ft.Divider())
                continue
            elif re.match(r"^$", md_line):  # ignore blank lines
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
            p.page_audio = audio_match.group(1)
            continue

        # Headings
        elif re.match(r"^#\s", md_line):
            heading_text = md_line[2:].strip()
            if heading_text:  # Only process non-empty headings
                # Generate heading ID with validation
                try:
                    heading_id = re.sub(r'[^\w-]', '', heading_text.lower().replace(' ', '-'))
                    if not heading_id:  # If empty after processing
                        heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                    if len(heading_id) > 100:  # Prevent excessively long IDs
                        heading_id = heading_id[:100]
                except Exception as e:
                    print(f"Error generating heading ID for '{heading_text}': {str(e)}")
                    heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                controls.append(HeadingOne(heading_text, id=heading_id))
            continue

        elif re.match(r"^##\s", md_line):
            heading_text = md_line[3:].strip()
            if heading_text:  # Only process non-empty headings
                # Generate heading ID with validation
                try:
                    heading_id = re.sub(r'[^\w-]', '', heading_text.lower().replace(' ', '-'))
                    if not heading_id:  # If empty after processing
                        heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                    if len(heading_id) > 100:  # Prevent excessively long IDs
                        heading_id = heading_id[:100]
                except Exception as e:
                    print(f"Error generating heading ID for '{heading_text}': {str(e)}")
                    heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                controls.append(HeadingTwo(heading_text, id=heading_id))
                if heading_text not in ['Q&A', 'References']:
                    p.page_headings.append(heading_text)
            continue

        elif re.match(r"^###\s", md_line):
            heading_text = md_line[3:].strip()
            if heading_text:  # Only process non-empty headings
                # Generate heading ID with validation
                try:
                    heading_id = re.sub(r'[^\w-]', '', heading_text.lower().replace(' ', '-'))
                    if not heading_id:  # If empty after processing
                        heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                    if len(heading_id) > 100:  # Prevent excessively long IDs
                        heading_id = heading_id[:100]
                except Exception as e:
                    print(f"Error generating heading ID for '{heading_text}': {str(e)}")
                    heading_id = f"heading-{hash(heading_text)}"  # Fallback to hash
                controls.append(HeadingThree(heading_text, id=heading_id))
                p.page_headings.append(heading_text)
            continue

        # Blank lines, blank quotes
        elif re.match(r"^$|^> *$", md_line):
            pass

        # Quotes
        elif md_line.startswith(">"):
            controls.append(Quote(md_line))
            continue

        # Links
        link_match = re.match(link_pattern, md_line)
        if link_match:
            page_ref, heading_ref, display_text = link_match.groups()
            controls.append(ft.ListTile(
                title=ft.Text(display_text),
                leading=ft.Icon(ft.Icons.LINK),
                data=(page_ref, heading_ref),
                on_click=lambda e, g=g: NavigationHandler(g).navigate(e.control.data[0], e.control.data[1]),
            ))
            continue
            
        # Normal lines
        else:
            controls.append(Paragraph(md_line))

    p.page_controls = ft.Column(
        controls=controls,
        expand=True,
        scroll=ft.ScrollMode.AUTO,
        spacing=10,
        tight=True,
        height=600,  # Set minimum height
    )

    return p
