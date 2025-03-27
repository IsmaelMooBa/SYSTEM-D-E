import flet as ft

def main(page: ft.Page):
    page.title = "Mi Aplicación con Flet"
    page.add(ft.Text("¡Hola, Flet!"))

ft.app(target=main)
