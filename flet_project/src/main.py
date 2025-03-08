import flet as ft

from flet_project.src.copy_files import copy_audio_files, copy_markdown_files
from flet_project.src.helpers import load_initial_page
from flet_project.src.markdown_processing import process_markdown
from flet_project.src.project_data import ProjectData
from flet_project.src.index import make_index


def main(page: ft.Page):
    g = ProjectData()
    copy_markdown_files(g)
    copy_audio_files(g)
    index_controls = make_index(g)
    dynamic_content = load_initial_page(g)
    initial_page = dynamic_content.get_container()

    def toggle_sidemenu(e):
        page.drawer.open = not page.drawer.open
        page.update()

    def handle_menu_click(e):
        """Handle menu item clicks to load markdown content"""
        new_content = process_markdown(page, g, e)
        dynamic_content.update_content(new_content)
        page.drawer.open = False
        page.scroll_to()

        # unselect all other tiles
        for item in index_controls.controls:
            if type(item) is ft.ListTile:
                item.selected = False
                item.update()

        # select the one that was clicked.
        if type(e.control) is ft.ListTile:
            e.control.selected = True
            e.control.update()
        page.update()

    # Configure page
    page.title = g.project_name
    page.scroll = "auto"
    page.padding = 0
    page.spacing = 0

    # AppBar with menu icon
    page.appbar = ft.AppBar(
        title=ft.Text(g.project_name),
        adaptive=True,
        leading=ft.IconButton(
            ft.Icons.MENU_OUTLINED,
            on_click=toggle_sidemenu,
        ),
    )

    # NavigationDrawer for sidemenu
    # Add click handlers to menu items
    for control in index_controls.controls:
        if hasattr(
            control, "data"
        ):  # Only add handlers to controls with markdown paths
            control.on_click = handle_menu_click

    page.drawer = ft.NavigationDrawer(
        controls=[index_controls],
        open=True,
    )

    page.add(
        ft.Container(
            content=ft.Column(
                [
                    initial_page,
                ],
                expand=True,
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                width=1000,
                spacing=50,
            ),
            alignment=ft.alignment.center,
            expand=True,
            padding=ft.padding.symmetric(horizontal=100, vertical=10),
        )
    )


ft.app(main)

# TODO Start Button / no menu so start
# TODO Reference links
# TODO Audio player
# TODO Next button
# TODO Export Android App
