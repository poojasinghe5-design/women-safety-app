# 🛡️ SafeHer — AI-Powered Women Safety App

A comprehensive women safety application built with **Flutter**, **Firebase**, and a **Python FastAPI AI backend**.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🆘 **SOS Alert** | Hold button 3 sec → auto-alerts all emergency contacts via SMS + push notification |
| 📍 **Live Location Sharing** | Real-time GPS tracking shared with trusted contacts |
| 🎤 **Voice Activation** | Say a keyword (e.g. "help me") to trigger silent SOS |
| 👥 **Emergency Contacts** | Manage up to 5 trusted contacts who receive alerts |
| 📞 **Fake Call** | Trigger a realistic incoming call to exit uncomfortable situations |
| 🤖 **Unsafe Area Prediction** | AI model scores location safety (0–100) using crime patterns + time |
| 🎙️ **Audio Recording** | Automatically records audio during SOS, uploads to Firebase Storage |
| 📊 **Safety Reports** | View AI-generated heatmaps and area risk assessments |

---

## 📁 Project Structure

```
women_safety_app/
├── flutter_app/                    # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart               # Entry point
│   │   ├── app.dart                # Router + theme
│   │   ├── firebase_options.dart   # Firebase config (auto-generated)
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── home_screen.dart    # Main dashboard with SOS button
│   │   │   ├── sos_screen.dart     # Full-screen SOS activation
│   │   │   ├── map_screen.dart     # Live location map
│   │   │   ├── contacts_screen.dart
│   │   │   ├── fake_call_screen.dart
│   │   │   ├── safety_report_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── auth/
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart       # Firebase Auth + user profile
│   │   │   ├── sos_service.dart        # SOS trigger/cancel
│   │   │   ├── location_service.dart   # GPS tracking + Firestore sync
│   │   │   ├── audio_service.dart      # Recording + Firebase Storage upload
│   │   │   └── voice_service.dart      # Speech-to-text keyword detection
│   │   ├── widgets/
│   │   │   ├── quick_action_grid.dart
│   │   │   ├── safety_status_card.dart
│   │   │   └── nearby_alert_banner.dart
│   │   └── models/
│   └── pubspec.yaml
├── python_backend/                 # FastAPI AI backend
│   ├── main.py                     # App entry point
│   ├── requirements.txt
│   └── api/
│       ├── sos_router.py           # SOS trigger → SMS + push notifications
│       ├── location_router.py      # Location sharing APIs
│       ├── prediction_router.py    # AI safety score + unsafe zone detection
│       └── contacts_router.py      # Emergency contact management
└── firebase/
    ├── firestore.rules             # Security rules
    ├── firestore.indexes.json      # Composite indexes
    └── database_schema.json        # Full schema documentation
```

---

## 🚀 Setup Guide

### Step 1 — Firebase Project

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize in project root
firebase init firestore
```

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project: `safeher-app`
3. Enable **Authentication** → Email/Password
4. Enable **Cloud Firestore** (Start in production mode)
5. Enable **Firebase Storage**
6. Enable **Cloud Messaging** (for push notifications)
7. Generate **Service Account Key** → Project Settings → Service Accounts → Generate new private key → save as `python_backend/serviceAccountKey.json`

---

### Step 2 — Flutter App Setup

```bash
cd flutter_app

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter (auto-generates firebase_options.dart)
flutterfire configure

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

**Android** — Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** — Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>SafeHer needs location for emergency alerts</string>
<key>NSMicrophoneUsageDescription</key>
<string>SafeHer records audio during emergencies</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>SafeHer listens for your voice SOS keyword</string>
```

---

### Step 3 — Python AI Backend

```bash
cd python_backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy your Firebase service account key here
cp ~/Downloads/serviceAccountKey.json .

# Set environment variables
export TWILIO_ACCOUNT_SID="your_twilio_sid"
export TWILIO_AUTH_TOKEN="your_twilio_token"
export TWILIO_PHONE_NUMBER="+1XXXXXXXXXX"

# Start server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Update the base URL in `flutter_app/lib/services/sos_service.dart`:
```dart
final _dio = Dio(BaseOptions(baseUrl: 'https://YOUR_SERVER_IP:8000/api'));
```

For production, deploy to **Google Cloud Run**, **Railway**, or **Render**.

---

### Step 4 — SMS Alerts (Twilio)

1. Sign up at [twilio.com](https://www.twilio.com)
2. Get a phone number
3. Set `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` env vars
4. Verify contact phone numbers in Twilio console (free tier requirement)

---

### Step 5 — Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

---

## 🤖 AI Prediction Model — Production Upgrade

The current prediction uses rule-based scoring. To upgrade to a real ML model:

```python
# Install additional deps
pip install scikit-learn pandas geopandas

# Data sources to integrate:
# 1. NCRB (National Crime Records Bureau) - data.gov.in
# 2. OpenStreetMap overpy API - street lights, police stations
# 3. Historical user reports from Firestore
# 4. Train: RandomForest or XGBoost on (lat, lng, hour, day_of_week) → risk_score
# 5. Use DBSCAN clustering for hotspot detection
```

---

## 🔑 Environment Variables

| Variable | Required | Description |
|---|---|---|
| `TWILIO_ACCOUNT_SID` | ✅ | Twilio account SID for SMS |
| `TWILIO_AUTH_TOKEN` | ✅ | Twilio auth token |
| `TWILIO_PHONE_NUMBER` | ✅ | Your Twilio phone number |
| `GOOGLE_MAPS_API_KEY` | ✅ | For map display in Flutter |

---

## 📱 Key Flutter Dependencies

| Package | Purpose |
|---|---|
| `firebase_*` | Auth, Firestore, Storage, Messaging |
| `geolocator` | GPS location tracking |
| `google_maps_flutter` | Map display |
| `speech_to_text` | Voice keyword detection |
| `record` | Audio recording |
| `telephony` | SMS (backup, Android) |
| `sensors_plus` | Shake detection |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |

---

## 🏗️ Architecture

```
Flutter App
    │
    ├── Firebase (Auth + Firestore + Storage + FCM)
    │       │
    │       └── Real-time sync (location, SOS status)
    │
    └── Python FastAPI Backend
            │
            ├── SOS Router → Twilio SMS + FCM Push
            ├── Prediction Router → AI Safety Score
            └── Location Router → Share Management
```

---

## ⚠️ Legal & Compliance

- Request only necessary permissions
- Inform users about data collection (Privacy Policy required)
- Audio recording must be disclosed to users
- Comply with local laws for location tracking
- Data stored in Firebase is encrypted at rest

---

## 🤝 Contributing

Pull requests welcome. For major changes, open an issue first.

---

## 📄 License

MIT License — Free to use, modify, and distribute.

---

*Built with ❤️ for women's safety*
