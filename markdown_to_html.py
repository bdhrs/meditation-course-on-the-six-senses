import markdown
import re
import subprocess
import os

from mkdocs_project.main import copy_files
from mkdocs_project.main import process_md_files


def replace_image_links(markdown_content):
    pattern = r"!\[\[(.*?)\]\]"
    replacement = r"**Listen to: \1**"
    return re.sub(pattern, replacement, markdown_content)


def replace_summary_details(markdown_content):
    pattern = r"%%(.*?)%%"
    replacement = r"<details><summary>Transcript</summary>\1</details>"
    markdown_content = re.sub(pattern, replacement, markdown_content, flags=re.DOTALL)
    return markdown_content


def convert_markdown_to_html(markdown_file_path, html_file_path):
    try:
        with open(markdown_file_path, "r", encoding="utf-8") as f:
            markdown_content = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {markdown_file_path}")
        return

    markdown_content = replace_image_links(markdown_content)
    markdown_content = replace_summary_details(markdown_content)
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
            color: lightgray;
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
        with open(html_file_path, "w", encoding="utf-8") as f:
            f.write(html_template)
        print("Converting to HTML")
    except Exception as e:
        print(f"Error writing to file: {e}")


def convert_html_to_ebooks(html_file_path, output_dir="output"):
    """
    Converts an HTML file to MOBI and EPUB using pandoc.

    Args:
        html_file_path: Path to the input HTML file.
        output_dir: Directory to save the output MOBI and EPUB files.
    """
    try:
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        base_name = os.path.splitext(os.path.basename(html_file_path))[0]
        epub_file_path = os.path.join(output_dir, f"{base_name}.epub")

        # Check if pandoc is installed
        try:
            subprocess.run(["pandoc", "--version"], check=True, capture_output=True)
        except (FileNotFoundError, subprocess.CalledProcessError):
            print("Error: pandoc is not installed or not in the system's PATH.")
            print("Please install pandoc to convert to MOBI and EPUB.")
            return

        # Convert to EPUB
        print("Converting to EPUB")
        subprocess.run(
            ["pandoc", html_file_path, "-o", epub_file_path],
            check=True,
            capture_output=True,
            text=True,
        )

    except subprocess.CalledProcessError as e:
        print(f"Error during conversion: {e}")
        print(f"Stdout: {e.stdout}")
        print(f"Stderr: {e.stderr}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def zip_mp3s(source_dir, output_filename):
    import os
    import zipfile

    try:
        print("Zipping MP3s")
        with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(source_dir):
                for file in files:
                    if file.endswith(".mp3"):
                        file_path = os.path.join(root, file)
                        zipf.write(file_path, os.path.relpath(file_path, source_dir))
    except Exception as e:
        print(f"Error zipping mp3 files: {e}")


if __name__ == "__main__":
    copy_files()
    process_md_files()
    markdown_file = "output/Meditation Course on the Six Senses.md"
    html_file = "output/Meditation Course on the Six Senses.html"
    convert_markdown_to_html(markdown_file, html_file)
    convert_html_to_ebooks(html_file)
    zip_mp3s("output/Meditation Course on the Six Senses/assets/audio", "output/mp3s.zip")
