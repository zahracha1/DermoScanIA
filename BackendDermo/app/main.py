from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.routes.predict import router as predict_router, load_model

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Chargement du modèle au démarrage
    load_model()
    yield
    # Nettoyage à l'arrêt
    print("Serveur arrêté.")

app = FastAPI(
    title="DermoScan AI API",
    description="API de classification de lésions cutanées (Bénin/Malin)",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS — permet à Flutter Web/Mobile de communiquer
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En prod : remplacer par votre domaine
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(predict_router, prefix="/api/v1", tags=["Prédiction"])

@app.get("/health")
async def health():
    return {"status": "ok", "service": "DermoScan AI"}