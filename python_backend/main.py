from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials
import logging

from api.sos_router import router as sos_router
from api.location_router import router as location_router
from api.prediction_router import router as prediction_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    if not firebase_admin._apps:
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred)
    logger.info("SafeHer backend started")
    yield

app = FastAPI(title="SafeHer AI Backend", version="1.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])
app.include_router(sos_router, prefix="/api/sos", tags=["SOS"])
app.include_router(location_router, prefix="/api/location", tags=["Location"])
app.include_router(prediction_router, prefix="/api/prediction", tags=["AI Prediction"])

@app.get("/health")
async def health():
    return {"status": "ok", "service": "SafeHer AI Backend"}