from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List

router = APIRouter()


class EmergencyContact(BaseModel):
    name: str
    phone: str
    relationship: str
    userId: Optional[str] = None


@router.post("/add/{user_id}")
async def add_contact(user_id: str, contact: EmergencyContact):
    from firebase_admin import firestore
    from google.cloud.firestore_v1 import ArrayUnion
    db = firestore.client()
    db.collection("users").document(user_id).update({
        "emergencyContacts": ArrayUnion([contact.dict()])
    })
    return {"success": True}


@router.get("/{user_id}")
async def get_contacts(user_id: str):
    from firebase_admin import firestore
    db = firestore.client()
    doc = db.collection("users").document(user_id).get()
    if not doc.exists:
        return {"contacts": []}
    return {"contacts": doc.to_dict().get("emergencyContacts", [])}