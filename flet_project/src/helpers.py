from flet_project.src.project_data import ProjectData
import flet as ft


class DynamicContent:
    def __init__(self, g: ProjectData):
        self.g = g
        self.container = ft.Column(
            controls=[]
        )

    def update_content(self, content):
        """Update content with processed markdown controls"""
        if isinstance(content, ft.Column):
            self.container.controls = content.controls

        if self.container.page:  # Only update if added to page
            self.container.update()

    def get_container(self):
        return self.container

