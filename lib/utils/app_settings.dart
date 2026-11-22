import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AppSettings {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static final ValueNotifier<double> textScale = ValueNotifier(1.0);
  static final ValueNotifier<bool> isTtsEnabled = ValueNotifier(false);

  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    if (!isTtsEnabled.value) return;
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  static Future<void> speakForce(String text) async {
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}