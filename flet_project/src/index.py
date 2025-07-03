import re
import flet as ft

from flet_project.src.helpers import ProjectData
from flet_project.src.navigation import NavigationHandler


def make_index(g: ProjectData):
    print("Making index")

    controls: list[ft.Control] = []

    for file_path in sorted(g.markdown_assets_dir.iterdir()):
        # file names either contain
        # '1. Title' in which case they are headings
        # '1.1. Section' in in which case they must be clickable links

        if re.match("^\d*\. ", file_path.stem):
            controls.append(
                ft.Container(
                    content=ft.Text(
                        value=file_path.stem,
                        data=file_path.stem,
                        color=ft.Colors.BLUE_100,
                    ),
                    padding=ft.padding.symmetric(horizontal=10, vertical=0),
                )
            )
        else:
            list_tile = ft.ListTile(
                title=ft.Text(file_path.stem), 
                data=file_path.stem,
                dense=True,
                selected_color=ft.Colors.BLUE_500,
                selected_tile_color=ft.Colors.BLUE_50,
                on_click=lambda e, g=g: NavigationHandler(g).navigate(e.control.data, "")
            )
            list_tile.ink = True 
            list_tile.selected_color = ft.Colors.BLUE_500
            controls.append(list_tile)

    return ft.Column(controls=controls, scroll=ft.ScrollMode.AUTO, spacing=2)
