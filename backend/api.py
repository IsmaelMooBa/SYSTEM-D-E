from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"mensaje": "Hola desde Python con FastAPI"}

# Ejecutar con: uvicorn api:app --reload
