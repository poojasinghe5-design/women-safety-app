import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

class LocationService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;
  bool _isSharingContinuous = false;

  Position? get lastPosition => _lastPosition;
  bool get isSharingContinuous => _isSharingContinuous;

  Future<bool> requestPermissions() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentLocation() async {
    final hasPerms = await requestPermissions();
    if (!hasPerms) return null;
    _lastPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return _lastPosition;
  }

  Future<void> startTracking() async {
    final hasPerms = await requestPermissions();
    if (!hasPerms) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPositionUpdate);
  }

  Future<void> startContinuousSharing() async {
    _isSharingContinuous = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
      _lastPosition = pos;
      await _db.collection('live_locations').doc(uid).set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'accuracy': pos.accuracy,
        'speed': pos.speed,
        'timestamp': FieldValue.serverTimestamp(),
        'isSOS': true,
      });
    });
  }

  void stopContinuousSharing() {
    _isSharingContinuous = false;
    _positionSub?.cancel();
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _db.collection('live_locations').doc(uid).update({'isSOS': false});
    }
  }

  void _onPositionUpdate(Position pos) {
    _lastPosition = pos;
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _db.collection('live_locations').doc(uid).set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'isSOS': false,
      }, SetOptions(merge: true));
    }
  }

  Stream<DocumentSnapshot> watchLocation(String uid) {
    return _db.collection('live_locations').doc(uid).snapshots();
  }

  void dispose() {
    _positionSub?.cancel();
  }
}