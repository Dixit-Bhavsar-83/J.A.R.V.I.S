import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechController extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  bool  _speechEnabled = false;
  String _lastWords    = '';
  String _localeId     = 'en_US';     // default locale

  // ───── getters ─────
  bool   get speechEnabled => _speechEnabled;
  String get lastWords     => _lastWords;
  bool   get isListening   => _speech.isListening;
  bool   get hasText       => _lastWords.trim().isNotEmpty;

  SpeechController() {
    _initSpeech();
  }

  // ───── init ─────
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (err) => debugPrint('Speech error: $err'),
      );
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    }
    notifyListeners();
  }

  // ───── public actions ─────
  Future<void> startListening({String? locale}) async {
    if (!_speechEnabled) return;
    _localeId = locale ?? _localeId;

    await _speech.listen(
      localeId: _localeId,
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        _lastWords = result.recognizedWords;
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    notifyListeners();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    notifyListeners();
  }

  /// Clear captured words & stop microphone
  Future<void> reset() async {
    await cancelListening();
    _lastWords = '';
    notifyListeners();
  }
}