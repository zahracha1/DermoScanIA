import json
import numpy as np
import tensorflow as tf
from fastapi import APIRouter, File, UploadFile, HTTPException
from pydantic import BaseModel
from app.utils.preprocessing import preprocess_image

router = APIRouter()

MODEL = None
CONFIG = None

def load_model():
    global MODEL, CONFIG
    try:
        MODEL = tf.keras.models.load_model(
            "app/model/dermoscan_b2_best.keras",
            compile=False
        )
        with open("app/model/inference_config.json", "r") as f:
            CONFIG = json.load(f)
        print(f" Modèle chargé | Seuil : {CONFIG['best_threshold']}")
    except Exception as e:
        print(f" Erreur : {e}")
        raise

class PredictionResponse(BaseModel):
    label: str
    label_fr: str
    confidence: float
    probability: float
    threshold: float
    advice: str
    risk_level: str

def _is_image_bytes(data: bytes) -> bool:
    """
    Détection par magic bytes — fiable même sans content_type.
    JPEG : FF D8 FF
    PNG  : 89 50 4E 47
    BMP  : 42 4D
    WEBP : 52 49 46 46
    """
    if len(data) < 4:
        return False
    if data[:3] == b'\xff\xd8\xff':          # JPEG
        return True
    if data[:4] == b'\x89PNG':               # PNG
        return True
    if data[:2] == b'BM':                    # BMP
        return True
    if data[:4] == b'RIFF' and data[8:12] == b'WEBP':  # WEBP
        return True
    return False

@router.post("/predict", response_model=PredictionResponse)
async def predict(file: UploadFile = File(...)):
    if MODEL is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")

    try:
        image_bytes = await file.read()

        # Vérification par magic bytes (pas par content_type)
        if not _is_image_bytes(image_bytes):
            raise HTTPException(
                status_code=400,
                detail="Le fichier doit être une image (jpg, png...)"
            )

        processed = preprocess_image(image_bytes)
        prob = float(MODEL.predict(processed, verbose=0)[0][0])
        threshold = CONFIG["best_threshold"]

        is_malignant = prob >= threshold
        label    = "malignant" if is_malignant else "benign"
        label_fr = "Malin"     if is_malignant else "Bénin"

        confidence = round((prob if is_malignant else 1 - prob) * 100, 1)

        if prob < 0.3:
            risk_level = "low"
        elif prob < threshold:
            risk_level = "medium"
        else:
            risk_level = "high"

        advice = (
            "Cette lésion présente des caractéristiques qui méritent "
            "une attention médicale urgente. Consultez un dermatologue "
            "dans les plus brefs délais pour un examen approfondi."
            if is_malignant else
            "La lésion semble bénigne. Continuez à surveiller "
            "tout changement de taille, de couleur ou de forme. "
            "Un contrôle annuel chez le dermatologue est recommandé."
        )

        return PredictionResponse(
            label=label,
            label_fr=label_fr,
            confidence=confidence,
            probability=round(prob, 4),
            threshold=threshold,
            advice=advice,
            risk_level=risk_level,
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de l'analyse : {str(e)}"
        )