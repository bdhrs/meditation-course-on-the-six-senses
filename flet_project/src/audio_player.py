import os
from datetime import timedelta

import flet as ft
from flet import CrossAxisAlignment, MainAxisAlignment, OptionalNumber


class AudioPlayer(ft.Container):
    def __init__(
        self,
        page: ft.Page,
        src_dir: str | None,
        curr_idx: int | None = 0,
        font_family: str | None = None,
        controls_width: OptionalNumber = None,
        controls_vertical_alignment: MainAxisAlignment = MainAxisAlignment.NONE,
        controls_horizontal_alignment: CrossAxisAlignment = CrossAxisAlignment.NONE,
        *args,
        **kwargs,
    ):
        super().__init__(*args, **kwargs)
        self.page_ = page
        self.controls_width = controls_width
        self.font_family = font_family

        self.src_dir = src_dir
        self.curr_idx = curr_idx
        self.src_dir_contents = [
            os.path.join(self.src_dir, folder_content)
            for folder_content in os.listdir(self.src_dir)
            if folder_content.split(".")[-1] == "mp3"
            and not os.path.isdir(os.path.join(self.src_dir, folder_content))
        ]

        self.curr_song_name = self.src_dir_contents[self.curr_idx]
        self.seek_bar = ft.ProgressBar(width=self.controls_width)

        # for elapsed time and duration
        self.times_row = ft.Row(
            alignment=ft.MainAxisAlignment.SPACE_BETWEEN,
            width=self.controls_width,
        )

        # play pause next buttons
        self.play_controls = ft.Container(
            ft.Column(
                [
                    ft.Row(
                        [
                            # ft.Text(),  # placeholder, nothing to be placed here
                            ft.IconButton(
                                icon=ft.icons.SKIP_PREVIOUS_SHARP,
                                data="prev",
                                on_click=self.prev_next_music,
                            ),
                            play_pause_btn := ft.IconButton(
                                icon=ft.icons.PLAY_ARROW, on_click=self.play_pause
                            ),
                            ft.IconButton(
                                icon=ft.icons.SKIP_NEXT_SHARP,
                                data="next",
                                on_click=self.prev_next_music,
                            ),
                        ],
                        alignment=ft.MainAxisAlignment.CENTER,
                        spacing=0,
                    ),
                    ft.Container(
                        ft.Row(
                            [
                                ft.IconButton(
                                    icon=ft.icons.ADD,
                                    data="inc",
                                    on_click=self.change_vol,
                                    icon_size=18,
                                ),
                                ft.IconButton(
                                    icon=ft.icons.REMOVE,
                                    data="dec",
                                    on_click=self.change_vol,
                                    icon_size=18,
                                ),
                            ],
                            spacing=0,
                            # wrap=True,
                            alignment=ft.MainAxisAlignment.CENTER,
                        ),
                        # border=ft.border.all(2, ft.colors.PINK),
                    ),
                ],
                spacing=0,
                # horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            ),
            width=page.width,
            alignment=ft.alignment.center,
            # border=ft.border.all(2, ft.colors.PURPLE),
            margin=0,
        )

        self.contents = [self.seek_bar, self.times_row, self.play_controls]

        self.content = ft.Column(
            self.contents,
            alignment=controls_vertical_alignment,
            horizontal_alignment=controls_horizontal_alignment,
        )

        self.audio = ft.Audio(
            src=self.src_dir_contents[self.curr_idx],
            volume=1,
            on_loaded=self._show_controls,
            on_state_changed=lambda _: setattr(
                self, "curr_state", _.data
            ),  # equivalent of self.curr_state = _.data
            on_position_changed=self._update_controls,
        )
        self.page_.overlay.append(self.audio)
        self.page_.update()

        self.play_pause_btn = play_pause_btn
        self.playing = False

        self.width = self.controls_width
        # self.border = ft.border.all(2, ft.colors.PURPLE)

        # contents = ft.Column([self.seek_bar])

    def change_vol(self, e):
        if e.control.data == "inc":
            self.audio.volume += 0.1
        elif e.control.data == "dec":
            self.audio.volume -= 0.1
        self.audio.update()

    def prev_next_music(self, e):
        old_audio_src = self.audio.src
        try:
            old_audio_state = self.curr_state
        except:  # when user has not changed the state, that is, control is just added to the page
            old_audio_state = "paused"
        self.audio.pause()
        if e.control.data == "next":
            idx = self.curr_idx + 1
            if idx >= len(self.src_dir_contents):
                idx = len(self.src_dir_contents) - 1
        elif e.control.data == "prev":
            idx = self.curr_idx - 1
            if idx <= 0:
                idx = 0
        self.curr_idx = idx

        new_path = os.path.join(self.src_dir, self.src_dir_contents[self.curr_idx])
        self.curr_song_name = self.src_dir_contents[self.curr_idx]

        # if it is the same song as the old one, resume the audo and bail out
        if old_audio_src == new_path:
            if old_audio_state == "playing":
                self.audio.resume()
            return

        self.audio.src = new_path
        self.duration = self.audio.get_duration()

        if old_audio_state == "playing":
            self.play_pause_btn.icon = ft.icons.PAUSE
            # too hacky way
            self.audio.autoplay = True
        elif old_audio_state == "paused":
            self.play_pause_btn.icon = ft.icons.PLAY_ARROW

        self.page_.update()
        self.audio.autoplay = False

    def play_pause(self, e):
        if self.playing:
            self.audio.pause()
            self.playing = False
            self.play_pause_btn.icon = ft.icons.PLAY_ARROW
        else:
            self.audio.resume()
            self.playing = True
            self.play_pause_btn.icon = ft.icons.PAUSE
        self.page_.update()

    # executed when audio is loaded
    def _show_controls(self, e):
        self.seek_bar.value = 0
        self.duration = self.audio.get_duration()

        elapsed_time, duration = self._calculate_formatted_times(0)

        self._update_times_row(elapsed_time, duration)

    def _update_controls(self, e):
        curr_time = int(e.data)  # the elapsed time
        try:
            self.seek_bar.value = curr_time / self.duration
        except AttributeError:
            self.duration = self.audio.get_duration()
        finally:
            self.seek_bar.value = curr_time / self.duration

        elapsed_time, duration = self._calculate_formatted_times(curr_time)

        self._update_times_row(elapsed_time, duration)

    def _calculate_formatted_times(self, elapsed_time: int):
        formatted_elapsed_time = self._format_timedelta_str(
            str(timedelta(milliseconds=elapsed_time))
        )
        formatted_time_duration = self._format_timedelta_str(
            str(timedelta(milliseconds=self.duration))
        )

        return formatted_elapsed_time, formatted_time_duration

    def _update_times_row(self, elapsed_time, time_duration):
        self.times_row.controls = [
            ft.Text(elapsed_time, font_family=self.font_family),
            ft.Text(time_duration, font_family=self.font_family),
        ]

        self.page_.update()

    # request this only when you have done timedelta(milliseconds=...)
    @staticmethod
    def _format_timedelta_str(timedelta_milliseconds_str: str):
        time_ = timedelta_milliseconds_str.split(":")  # the whole split string
        seconds_field = time_[-1]
        seconds = seconds_field.split(".")[0]  # situation: 0:03:40.something
        try:
            microseconds = seconds_field.split(".")[1]  # if it exists
        except:
            pass  # if the microseconds field doesn't exist
        else:
            # basically, this is the process of rounding
            # first, convert the parts into numbers
            # process
            # round the output and convert into string
            time_[-1] = str(round(float(eval(seconds + "." + microseconds))))

        # the hours place
        if len(time_[0]) == 1 and time_[0] == "0":
            del time_[0]

        return ":".join(time_)