import flet as ft
import re

font_family = "Noto Serif"


class StyledText(ft.Text):
    def __init__(self, value: str, size: int, weight=ft.FontWeight.NORMAL):
        spans = self.parse_inline_styles(value)
        super().__init__(
            size=size,
            font_family=font_family,
            selectable=True,
            weight=weight,
            spans=spans,
        )

    def parse_inline_styles(self, text):
        # Regex pattern to match *italic* and **bold** text within single paragraph
        pattern = r"(\*\*.*?\*\*)|(\*.*?\*)"
        spans = []
        last_end = 0

        for match in re.finditer(pattern, text):
            # Add preceding plain text
            if match.start() > last_end:
                spans.append(ft.TextSpan(text[last_end : match.start()]))

            # Add styled text
            if match.group(1):  # Bold
                spans.append(
                    ft.TextSpan(
                        text=match.group(1)[2:-2],
                        style=ft.TextStyle(weight=ft.FontWeight.BOLD),
                    )
                )
            else:  # Italic
                spans.append(
                    ft.TextSpan(
                        text=match.group(2)[1:-1], style=ft.TextStyle(italic=True)
                    )
                )

            last_end = match.end()

        # Add remaining plain text
        if last_end < len(text):
            spans.append(ft.TextSpan(text[last_end:]))

        return spans


class HeadingOne(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value, size=32, weight=ft.FontWeight.BOLD)


class HeadingTwo(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value, size=24, weight=ft.FontWeight.BOLD)


class HeadingThree(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value, size=18, weight=ft.FontWeight.BOLD)


class Paragraph(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value, size=18)


class Quote(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value[2:], size=18)
        self.color = ft.Colors.BLUE_300
        self.padding = ft.padding.symmetric(vertical=150, horizontal=150)


class TranscriptContent(StyledText):
    def __init__(self, value: str):
        super().__init__(value=value, size=16)
        self.color = ft.Colors.BLUE_100


class Transcript(ft.ExpansionTile):
    def __init__(self, content: list):
        super().__init__(
            title=ft.Text(
                "Transcript",
                size=18,
                color=ft.Colors.BLUE_300,
                font_family="Noto Serif",
            ),
            controls=[ft.Column(controls=content, spacing=10)],
            controls_padding=ft.padding.only(left=50, right=50, top=10, bottom=50),
        )
