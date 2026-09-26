from fastapi import APIRouter, BackgroundTasks
from pydantic import BaseModel
from typing import Optional
import os

router = APIRouter()

TWILIO_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
TWILIO_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
TWILIO_FROM = os.getenv("TWILIO_PHONE_NUMBER", "")


class SOSTriggerRequest(BaseModel):
    userId: str
    sosId: str
    lat: Optional[float] = None
    lng: Optional[float] = None


class SOSCancelRequest(BaseModel):
    userId: str


async def _send_alerts(user_id: str, lat: float, lng: float, sos_id: str):
    from firebase_admin import firestore, messaging
    db = firestore.client()
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        return
    user_data = user_doc.to_dict()
    user_name = user_data.get("name", "Someone")
    contacts = user_data.get("emergencyContacts", [])
    maps_link = f"https://maps.google.com/?q={lat},{lng}"
    sms_body = (
        f"🚨 EMERGENCY ALERT from {user_name}!\n"
        f"She needs help urgently.\n"
        f"📍 Live location: {maps_link}\n"
        f"Please call her or contact authorities immediately."
    )
    if TWILIO_SID and TWILIO_TOKEN:
        from twilio.rest import Client
        client = Client(TWILIO_SID, TWILIO_TOKEN)
        for contact in contacts:
            phone = contact.get("phone", "")
            if phone:
                try:
                    client.messages.create(
                        body=sms_body, from_=TWILIO_FROM, to=phone)
                except Exception as e:
                    print(f"SMS error: {e}")


@router.post("/trigger")
async def trigger_sos(req: SOSTriggerRequest, bg: BackgroundTasks):
    from firebase_admin import firestore
    from datetime import datetime
    db = firestore.client()
    db.collection("sos_alerts").document(req.sosId).update({
        "backendNotified": True,
        "notifiedAt": datetime.utcnow()
    })
    if req.lat and req.lng:
        bg.add_task(_send_alerts, req.userId, req.lat, req.lng, req.sosId)
    return {"success": True, "sosId": req.sosId}


@router.post("/cancel")
async def cancel_sos(req: SOSCancelRequest):
    from firebase_admin import firestore
    db = firestore.client()
    user_doc = db.collection("users").document(req.userId).get()
    if user_doc.exists:
        user_name = user_doc.to_dict().get("name", "User")
        contacts = user_doc.to_dict().get("emergencyContacts", [])
        if TWILIO_SID and TWILIO_TOKEN:
            from twilio.rest import Client
            client = Client(TWILIO_SID, TWILIO_TOKEN)
            for c in contacts:
                phone = c.get("phone", "")
                if phone:
                    try:
                        client.messages.create(
                            body=f"✅ {user_name} is safe now. SOS cancelled.",
                            from_=TWILIO_FROM, to=phone)
                    except Exception:
                        pass
    return {"success": True}


@router.get("/history/{user_id}")
async def sos_history(user_id: str):
    from firebase_admin import firestore
    db = firestore.client()
    alerts = (db.collection("sos_alerts")
              .where("userId", "==", user_id)
              .order_by("timestamp", direction=firestore.Query.DESCENDING)
              .limit(20).get())
    return {"alerts": [{"id": a.id, **a.to_dict()} for a in alerts]}