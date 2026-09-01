import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';

  String get currentLanguage => _currentLanguage;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setSpeechRate(0.4); // Slower for elderly patients
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
      if (kDebugMode) {
        print("TTS Service Initialized Successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing TTS: $e");
      }
    }
  }

  Future<void> setLanguage(String langCode) async {
    await init();
    _currentLanguage = langCode;
    try {
      await _flutterTts.setLanguage(langCode);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting language: $e");
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await init();
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print("TTS speak error: $e. Falling back to printing text: $text");
      }
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (kDebugMode) {
        print("TTS stop error: $e");
      }
    }
  }
}
