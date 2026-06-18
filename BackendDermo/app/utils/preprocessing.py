import cv2
import numpy as np
from PIL import Image, ImageFile
import io

ImageFile.LOAD_TRUNCATED_IMAGES = True

IMG_SIZE = 260  # Même que CFG['img_size']

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Préprocessing identique à l'entraînement :
    1. Décodage image
    2. Redimensionnement à 260x260
    3. Suppression des poils (blackhat + inpaint)
    4. CLAHE sur canal L
    Retourne un array float32 [0,255] shape (1, 260, 260, 3)
    """
    # Décoder l'image depuis bytes
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        # Fallback via PIL
        pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        img = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)
    
    # Convertir BGR → RGB (OpenCV lit en BGR)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Redimensionner
    img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
    img = img.astype(np.uint8)
    
    # ── 1. Suppression des poils ──────────────────────────────
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (9, 9))
    blackhat = cv2.morphologyEx(img, cv2.MORPH_BLACKHAT, kernel)
    gray_bh = cv2.cvtColor(blackhat, cv2.COLOR_RGB2GRAY)
    _, hair_mask = cv2.threshold(gray_bh, 10, 255, cv2.THRESH_BINARY)
    img = cv2.inpaint(img, hair_mask, inpaintRadius=3, flags=cv2.INPAINT_TELEA)
    
    # ── 2. CLAHE sur canal L ──────────────────────────────────
    lab = cv2.cvtColor(img, cv2.COLOR_RGB2LAB)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    lab[:, :, 0] = clahe.apply(lab[:, :, 0])
    img = cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)
    
    # Shape finale : (1, 260, 260, 3), float32, valeurs [0, 255]
    return img.astype(np.float32)[np.newaxis, ...]