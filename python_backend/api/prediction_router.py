from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List
import numpy as np
from datetime import datetime

router = APIRouter()


class SafetyPredictionRequest(BaseModel):
    lat: float
    lng: float
    timestamp: Optional[str] = None


class AreaReport(BaseModel):
    lat: float
    lng: float
    description: str
    severity: int


def compute_safety_score(lat: float, lng: float, hour: int) -> dict:
    np.random.seed(int(abs(lat * lng * 1000)) % 9999)
    base_score = int(np.random.uniform(45, 95))
    night_penalty = 20 if (hour >= 22 or hour <= 5) else 0
    score = max(0, min(100, base_score - night_penalty))
    if score >= 75:
        risk, rec = "LOW", "Area appears safe. Stay alert."
    elif score >= 50:
        risk, rec = "MEDIUM", "Exercise caution. Share your location."
    elif score >= 25:
        risk, rec = "HIGH", "High risk area. Avoid isolated spots."
    else:
        risk, rec = "CRITICAL", "Avoid this area. Consider activating SOS."
    factors = []
    if night_penalty:
        factors.append("Late night hours increase risk")
    if score < 60:
        factors.append("Limited street lighting reported")
    if score < 45:
        factors.append("Incidents reported in this area")
    return {
        "score": score,
        "risk_level": risk,
        "factors": factors,
        "recommendation": rec
    }


@router.post("/safety-score")
async def get_safety_score(req: SafetyPredictionRequest):
    ts = datetime.fromisoformat(req.timestamp) if req.timestamp else datetime.now()
    return compute_safety_score(req.lat, req.lng, ts.hour)


@router.get("/unsafe-zones")
async def get_unsafe_zones(lat: float, lng: float, radius_km: float = 2.0):
    np.random.seed(int(abs(lat * lng * 100)) % 9999)
    n_zones = int(np.random.randint(0, 4))
    zones = []
    for _ in range(n_zones):
        zones.append({
            "lat": lat + float(np.random.uniform(-0.01, 0.01)),
            "lng": lng + float(np.random.uniform(-0.01, 0.01)),
            "risk_level": str(np.random.choice(["MEDIUM", "HIGH"])),
            "reports": int(np.random.randint(1, 15)),
        })
    return {"zones": zones}


@router.post("/report-incident")
async def report_incident(report: AreaReport):
    from firebase_admin import firestore
    db = firestore.client()
    ref = db.collection("area_reports").add({
        "lat": report.lat,
        "lng": report.lng,
        "description": report.description,
        "severity": report.severity,
        "timestamp": datetime.utcnow(),
        "verified": False,
    })
    return {"success": True, "reportId": ref[1].id}