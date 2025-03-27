import flet as ft
from fastapi import FastAPI, File, UploadFile
import pandas as pd
import uvicorn
import os

app = FastAPI()

@app.post("/upload_csv")
async def upload_csv(file: UploadFile = File(...)):
    contents = await file.read()
    file_path = f"temp_{file.filename}"
    
    with open(file_path, "wb") as f:
        f.write(contents)

    df = pd.read_csv(file_path, header=None)  # Leer CSV sin encabezado
    os.remove(file_path)  # Eliminar archivo temporal
    
    csv_data = df.values.tolist()  # Convertir a lista
    filtered_numbers = [str(num) for num in df.values.flatten() if num <= 7]

    return {"csv_data": csv_data, "filtered_numbers": filtered_numbers}

def main(page: ft.Page):
    page.title = "Procesador de CSV"
    page.add(ft.Text("Servidor en ejecución..."))

ft.app(target=main, view=ft.WEB_BROWSER)

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
    # Iniciar el servidor FastAPI en segundo plano