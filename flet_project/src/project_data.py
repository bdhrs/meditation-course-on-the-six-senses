import flet as ft

from configparser import ConfigParser
from dataclasses import dataclass, field
from pathlib import Path

config = ConfigParser()
config.read("config.ini")
markdown_source = config["paths"]["source_folder"]


@dataclass
class PageData:
    page_title: str = ""
    page_path: str = Path()
    page_controls: ft.Control = None
    page_headings: list[str] = field(default_factory=list)
    page_audio: str = ""


@dataclass
class ProjectData:
    project_name = "Meditation Course on the Six Senses"

    markdown_source_dir = Path(markdown_source)
    markdown_assets_dir = Path("flet_project/src/assets/md")

    audio_source_dir = Path("waveform_project/Exported")
    audio_assets_dir = Path("flet_project/src/assets/audio")

    initial_page = Path("flet_project/src/assets/md/0.1. About the Course.md")

    pages_list: list[str] = field(default_factory=list)
    page_data: dict[PageData] = field(default_factory=dict)




