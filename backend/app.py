from fastapi import FastAPI, File, UploadFile
import pandas as pd
import uvicorn
import os

app = FastAPI()

@app.post("/upload_csv")
async def upload_csv(file: UploadFile = File(...)):
    contents = await file.read()
    file_path = f"temp_{file.filename}"

    # Guardar el archivo temporalmente
    with open(file_path, "wb") as f:
        f.write(contents)

    # Leer el CSV sin encabezado
    df = pd.read_csv(file_path, header=None)

    # Convertir a números, colocando NaN en valores no numéricos
    df = df.apply(pd.to_numeric, errors='coerce')

    # Eliminar archivo temporal
    os.remove(file_path)
    
    # Convertir a lista
    csv_data = df.values.tolist()

    # Filtrar valores menores o iguales a 7
    filtered_numbers = [str(num) for num in df.values.flatten() if pd.notna(num) and num <= 7]
    filtered_numbers = list(set(filtered_numbers))  # Eliminar duplicados

    return {"csv_data": csv_data, "filtered_numbers": filtered_numbers}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
