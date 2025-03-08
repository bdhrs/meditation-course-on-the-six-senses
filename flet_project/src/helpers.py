from flet_project.src.markdown_processing import process_markdown
from flet_project.src.project_data import ProjectData
import flet as ft


class DynamicContent:
    def __init__(self, g: ProjectData):
        self.g = g
        self.container = ft.Column(
            controls=[
                process_markdown(g=self.g, page=None, e=None, file_path=g.initial_page)
            ]
        )

    def update_content(self, content):
        """Update content with processed markdown controls"""
        if isinstance(content, ft.Column):
            self.container.controls = content.controls
        else:
            pass
            # processed = process_markdown(g=self.g, page=None, e=None, file_path=content)
            # self.container.controls = processed.controls

        if self.container.page:  # Only update if added to page
            self.container.update()

    def get_container(self):
        return self.container


def load_initial_page(g: ProjectData):
    return DynamicContent(g)
