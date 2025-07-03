from flet_project.src.project_data import ProjectData

class NavigationHandler:
    """Handles all navigation operations in the application"""
    
    def __init__(self, project_data: ProjectData):
        self.project_data = project_data
        
    def navigate(self, page_key: str, heading: str = None, page=None):
        """Main navigation method that handles both page and section navigation"""
        if page_key not in self.project_data.page_data:
            print(f"Error: Page {page_key} not found")
            return
            
        # Clear existing content
        self.project_data.content_container.content.controls = []
        
        # Load new page content
        self.project_data.content_container.content.controls = [
            self.project_data.page_data[page_key].page_controls
        ]
        self.project_data.content_container.update()
        
        # Handle scrolling
        if heading:
            self._scroll_to_heading(heading)
        elif page:
            page.scroll_to()
            
    def _scroll_to_heading(self, heading: str, scroll_offset: int = 80, scroll_duration: int = 1000):
        """Helper method to scroll to a specific heading with offset
        
        Args:
            heading: The heading ID to scroll to
            scroll_offset: Number of pixels to offset scroll position (default 80px for fixed header)
            scroll_duration: Scroll animation duration in milliseconds
        """
        if not heading:
            return
            
        # Get the main content column
        main_content = self.project_data.content_container.content.controls
        if not main_content or not main_content[0].controls:
            return
            
        # Search through all controls
        for control in main_content[0].controls:
            try:
                if (
                    hasattr(control, "id")
                    and control.id is not None
                    and isinstance(control.id, str)
                    and control.id == heading
                ):
                    # Verify control is visible and ready
                    if not hasattr(control, "scroll_to"):
                        continue
                        
                    # Scroll with offset
                    control.scroll_to(
                        duration=scroll_duration,
                        offset=scroll_offset
                    )
                    return
            except Exception as e:
                print(f"Navigation error: {str(e)}")
                continue
                
        print(f"Warning: Heading '{heading}' not found")
