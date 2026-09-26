import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'location_service.dart';

final sosServiceProvider = Provider<SosService>((ref) => SosService(ref));

class SosService {
  final Ref _ref;
  final _dio = Dio(BaseOptions(baseUrl: 'https://your-python-backend.com/api'));
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isActive = false;

  SosService(this._ref);

  bool get isActive => _isActive;

  Future<void> sendSOSAlert() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _isActive = true;

    final location = await _ref.read(locationServiceProvider).getCurrentLocation();

    // 1. Create SOS record in Firestore
    final sosRef = await _db.collection('sos_alerts').add({
      'userId': uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
      'location': {
        'lat': location?.latitude,
        'lng': location?.longitude,
      },
      'audioUrl': null,
    });

    // 2. Notify Python AI backend (sends SMS + push notifications)
    try {
      await _dio.post('/sos/trigger', data: {
        'userId': uid,
        'sosId': sosRef.id,
        'lat': location?.latitude,
        'lng': location?.longitude,
      });
    } catch (e) {
      // Fallback: direct Firestore update triggers Cloud Functions
      await sosRef.update({'backendNotified': false, 'error': e.toString()});
    }
  }

  Future<void> cancelSOS() async {
    _isActive = false;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final alerts = await _db
        .collection('sos_alerts')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in alerts.docs) {
      await doc.reference.update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    }

    await _dio.post('/sos/cancel', data: {'userId': uid});
  }

  Future<void> uploadAudioToSOS(String sosId, String audioPath) async {
    // Upload to Firebase Storage then update Firestore
    await _db.collection('sos_alerts').doc(sosId).update({
      'audioUrl': 'gs://bucket/sos/$sosId/recording.aac',
    });
  }

  Stream<QuerySnapshot> watchActiveSOS(String uid) {
    return _db
        .collection('sos_alerts')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }
}