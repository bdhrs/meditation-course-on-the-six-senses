import markdown
import re
import subprocess

from rich import print

from paths import ProjectPaths


def replace_audio_links(markdown_content):
    # Handle audio files
    audio_pattern = r"!\[\[(.*?\.mp3)\]\]"
    audio_replacement = r"**Listen to: \1**"
    markdown_content = re.sub(audio_pattern, audio_replacement, markdown_content)

    # Handle SVG images
    svg_pattern = r"!\[\[(.*?\.svg)\]\]"
    svg_replacement = r"![\1](assets/images/\1)"
    markdown_content = re.sub(svg_pattern, svg_replacement, markdown_content)

    return markdown_content


def replace_summary_details(markdown_content):
    pattern = r"%%(.*?)%%"
    replacement = r"<details><summary>Transcript</summary>\1</details>"
    markdown_content = re.sub(pattern, replacement, markdown_content, flags=re.DOTALL)
    return markdown_content


def add_header_anchors(markdown_content):
    """Convert markdown headers to HTML with anchor IDs"""

    def process_header(match):
        header_text = match.group(2)
        # Generate ID using same logic as convert_links
        # Generate ID by keeping only alphanumeric chars and spaces
        header_id = (
            "".join(c for c in header_text if c.isalnum() or c == " ")
            .lower()
            .replace(" ", "-")
        )
        # Remove any remaining special characters
        header_id = "".join(c for c in header_id if c.isalnum() or c == "-")

        # Convert markdown header to HTML with anchor
        if match.group(1) == "#":
            return f'<h1 id="{header_id}">{header_text}</h1>'
        elif match.group(1) == "##":
            return f'<h2 id="{header_id}">{header_text}</h2>'
        elif match.group(1) == "###":
            return f'<h3 id="{header_id}">{header_text}</h3>'
        return match.group(0)

    # Match markdown headers (1-3 # symbols)
    return re.sub(
        r"^(#{1,3})\s+(.*)$", process_header, markdown_content, flags=re.MULTILINE
    )


def convert_links(match):
    # group(1) is always the target
    # group(2) is the display text (optional)
    target = match.group(1)
    display_text = match.group(2) or target

    if "#" in target:
        id_with_hash = target.split("#", 1)[1]
        id = id_with_hash.replace("#", "")
        # Generate ID by keeping only alphanumeric chars and spaces
        id = "".join(c for c in id if c.isalnum() or c == " ").lower().replace(" ", "-")
        # Remove any remaining special characters
        id = "".join(c for c in id if c.isalnum() or c == "-")
        return f'<a href="#{id}">{display_text}</a>'
    else:
        return display_text


def convert_markdown_to_html(pth: ProjectPaths):
    try:
        with open(pth.output_markdown_file, "r", encoding="utf-8") as f:
            markdown_content = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {pth.output_markdown_file}")
        return

    markdown_content = replace_audio_links(markdown_content)
    markdown_content = replace_summary_details(markdown_content)
    link_pattern = r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]"
    markdown_content = re.sub(link_pattern, convert_links, markdown_content)

    # First add header anchors to markdown
    markdown_content = add_header_anchors(markdown_content)

    # Then convert to HTML
    html_content = markdown.markdown(markdown_content)

    html_template = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meditation Course on the Six Senses</title>
    <style>
        body {{
            background-color: #000022;
            color: #ffffff;
            font-family: 'Noto Serif', serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }}
        blockquote {{
            color: lightblue;
        }}
        .container {{
            max-width: 800px;
            margin: 0 auto;
        }}
        details {{
            margin-bottom: 10px;
        }}
        summary {{
            padding: 10px;
            border: 1px solid #555;
            cursor: pointer;
        }}
        a {{
            color: lightblue;
            text-decoration: underline;
        }}
        a:hover {{
            color: white;
        }}
    </style>
</head>
<body>
    <div class="container">
        {html_content}
    </div>
</body>
</html>
"""

    try:
        with open(pth.output_html_file, "w", encoding="utf-8") as f:
            f.write(html_template)
        print("Converting to html")
    except Exception as e:
        print(f"Error writing to file: {e}")


def convert_html_to_ebooks(pth: ProjectPaths):
    try:
        # Convert to EPUB
        print("Converting to epub")
        subprocess.run(
            ["pandoc", pth.output_html_file, "-o", pth.output_epub_file],
            check=True,
            capture_output=True,
            text=True,
        )

        # Convert to .odt
        print("Converting to docx")
        try:
            subprocess.run(
                ["pandoc", pth.output_html_file, "-o", pth.output_docx_file],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"[red]Error code: {e.returncode}")
            print(f"[red]Standard Output: {e.stdout}")
            print(f"[red]Standard Error: {e.stderr}")

    except subprocess.CalledProcessError as e:
        print(f"[red]Error during conversion: {e}")
        print(f"[red]Stdout: {e.stdout}")
        print(f"[red]Stderr: {e.stderr}")
    except Exception as e:
        print(f"[red]An unexpected error occurred: {e}")


def zip_mp3s(pth: ProjectPaths):
    import os
    import zipfile

    try:
        print("Zipping mp3s")
        with zipfile.ZipFile(pth.output_mp3_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(pth.output_mkdocs_audio_assets_dir):
                for file in files:
                    if file.endswith(".mp3"):
                        file_path = os.path.join(root, file)
                        zipf.write(
                            file_path,
                            os.path.relpath(
                                file_path, pth.output_mkdocs_audio_assets_dir
                            ),
                        )
    except Exception as e:
        print(f"Error zipping mp3 files: {e}")
