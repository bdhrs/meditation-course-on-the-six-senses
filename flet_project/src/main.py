import flet as ft

from flet_project.src.copy_files import copy_audio_files, copy_markdown_files
from flet_project.src.markdown_processing import make_page_data
from flet_project.src.navigation import NavigationHandler
from flet_project.src.project_data import ProjectData
from flet_project.src.index import make_index


def main(page: ft.Page):
    g = ProjectData()
    copy_markdown_files(g)
    copy_audio_files(g)
    make_page_data(g)
    index_controls = make_index(g)

    def toggle_sidemenu(e):
        page.drawer.open = not page.drawer.open
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

    # Menu click handler using NavigationHandler
    def handle_menu_click(e):
        """Handle menu item clicks to load markdown content"""
        page.drawer.open = False
        page.scroll_to()

        # unselect all other tiles
        for item in index_controls.controls:
            if type(item) is ft.ListTile:
                item.selected = False
                item.update()

        # select and load content for clicked tile
        if type(e.control) is ft.ListTile:
            e.control.selected = True
            e.control.update()
            NavigationHandler(g).navigate(e.control.data, "")
            page.update()

    # NavigationDrawer for sidemenu
    # Add click handlers to menu items
    for control in index_controls.controls:
        if hasattr(control, "data"):  # Only add handlers to controls with markdown paths
            control.on_click = handle_menu_click

    page.drawer = ft.NavigationDrawer(
        controls=[index_controls],
        open=True,
    )

    # Main content container
    content_container = ft.Container(
        content=ft.Column(
            [],
            expand=True,
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            width=1000,
            spacing=10,
        ),
        alignment=ft.alignment.center,
        expand=True,
        padding=ft.padding.symmetric(horizontal=100, vertical=10),
    )
    
    page.add(content_container)

    # Set the content container in the global data object
    g.content_container = content_container


ft.app(main)

# TODO Start Button / no menu so start
# TODO Reference links
# TODO Audio player
# TODO Next button
# TODO Export Android App
