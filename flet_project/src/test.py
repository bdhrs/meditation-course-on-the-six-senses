import flet as ft


def main(page: ft.Page):
    page.title = "Flet App with Text Fields"

    data_dict = {
        "field_lemma_1": "",
        "field_lemma_2": "",
        "field_meaning_1": "",
        "field_pos": "",
    }
    pos_list = ["adj", "masc", "fem", "nt", "pr"]

    field_lemma_1 = ft.TextField(value=data_dict["field_lemma_1"], width=1000)
    field_lemma_2 = ft.TextField(value=data_dict["field_lemma_2"], width=1000)
    field_meaning_1 = ft.TextField(value=data_dict["field_meaning_1"], width=1000)
    field_pos = ft.Dropdown(
        # value=data_dict["field_pos"],
        width=1000,
        enable_filter=True,
        editable=True,
        options=[ft.dropdown.Option(item) for item in pos_list],
    )

    def update_data(e):
        data_dict[e.control.data] = e.control.value
        print(data_dict) # for debugging purposes

    field_lemma_1.data = "field_lemma_1"
    field_lemma_2.data = "field_lemma_2"
    field_meaning_1.data = "field_meaning_1"
    field_pos.data = "field_pos"

    field_lemma_1.on_change = update_data
    field_lemma_2.on_change = update_data
    field_meaning_1.on_change = update_data
    field_pos.on_change = update_data

    def load_data(e):
        field_lemma_1.value = data_dict["field_lemma_1"]
        field_lemma_2.value = data_dict["field_lemma_2"]
        field_meaning_1.value = data_dict["field_meaning_1"]
        field_pos.value = data_dict["field_pos"]
        page.update()

    def clear_data(e):
        field_lemma_1.value = ""
        field_lemma_2.value = ""
        field_meaning_1.value = ""
        field_pos.value = None
        page.update()

    load_button = ft.ElevatedButton("Load Data", on_click=load_data)
    clear_button = ft.ElevatedButton("Clear Data", on_click=clear_data)

    page.add(
        ft.Row([ft.Text("lemma_1:", width=200), field_lemma_1]),
        ft.Row([ft.Text("lemma_2:", width=200), field_lemma_2]),
        ft.Row([ft.Text("meaning_1:", width=200), field_meaning_1]),
        ft.Row([ft.Text("pos:", width=200), field_pos]),
        ft.Row([ft.Container(width=200), load_button, clear_button]),
    )


if __name__ == "__main__":
    ft.app(target=main)
