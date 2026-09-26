from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List

router = APIRouter()


class LocationShareRequest(BaseModel):
    userId: str
    contactIds: List[str]
    durationMinutes: Optional[int] = 60


@router.post("/share")
async def share_location(req: LocationShareRequest):
    from firebase_admin import firestore
    db = firestore.client()
    db.collection("location_shares").add({
        "userId": req.userId,
        "sharedWith": req.contactIds,
        "active": True
    })
    return {"success": True}


@router.delete("/share/{user_id}")
async def stop_sharing(user_id: str):
    from firebase_admin import firestore
    db = firestore.client()
    shares = (db.collection("location_shares")
              .where("userId", "==", user_id)
              .where("active", "==", True)
              .get())
    for s in shares:
        s.reference.update({"active": False})
    return {"success": True}