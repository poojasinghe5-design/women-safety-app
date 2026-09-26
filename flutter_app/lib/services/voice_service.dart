import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());

class VoiceService {
  final _speech = SpeechToText();
  bool _isListening = false;
  String _keyword = 'help me';
  Function()? _onKeywordDetected;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onStatus: _onStatus,
      onError: (e) => print('Voice error: $e'),
    );
  }

  void setKeyword(String keyword) => _keyword = keyword.toLowerCase();
  void setCallback(Function() callback) => _onKeywordDetected = callback;

  Future<void> startListening() async {
    if (_isListening) return;
    final available = await _speech.initialize();
    if (!available) return;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase();
        if (words.contains(_keyword)) {
          _onKeywordDetected?.call();
        }
      },
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 3),
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  void _onStatus(String status) {
    if (status == 'done' && _isListening) {
      // Auto-restart continuous listening
      Future.delayed(const Duration(milliseconds: 500), startListening);
    }
  }

  void dispose() {
    _speech.cancel();
  }
}