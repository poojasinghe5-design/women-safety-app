import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final shakeServiceProvider = Provider<ShakeService>((ref) => ShakeService());

class ShakeService {
  static const double _shakeThreshold = 15.0;
  static const int _shakeSlopTimeMs = 500;

  DateTime? _lastShakeTime;
  Function()? _onShake;

  void startListening(Function() onShake) {
    _onShake = onShake;
    accelerometerEventStream().listen((AccelerometerEvent event) {
      double acceleration = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      ) - 9.8;

      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > _shakeSlopTimeMs) {
          _lastShakeTime = now;
          _onShake?.call();
        }
      }
    });
  }

  void stopListening() {
    _onShake = null;
  }
}