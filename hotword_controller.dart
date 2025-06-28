// lib/controller/hotword_controller.dart

import 'package:flutter/foundation.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';  // PorcupineManager
import 'package:porcupine_flutter/porcupine_error.dart';   // PorcupineException
import 'package:audioplayers/audioplayers.dart';
import 'package:overlay_support/overlay_support.dart';     // 👈 overlay support
import 'package:jarvis/widgets/voice_overlay.dart';        // 👈 bottom bar widget

/// Wake-word "Jarvis" controller – custom .ppn फ़ाइल के साथ
class HotwordController {
  HotwordController({required this.onWake});

  final VoidCallback onWake;
  PorcupineManager? _manager;
  final _player = AudioPlayer();

  /// Initialize Porcupine
  Future<void> init() async {
    try {
      // NOTE: positional args → (accessKey, keywordPaths, wakeWordCallback)
      _manager = await PorcupineManager.fromKeywordPaths(
        'xLL5t+3FGFMwU8wcWOT87bRMju/lwbW7XLF+C2iyj/ZDFwj4yMDJKQ==', // 🔐 replace with your real Picovoice key
        ['/assets/ppn/jarvis_en_android_v3_0_0.ppn'],                         // ✅ custom .ppn path
        _wakeCallback,
      );
      await _manager!.start();
      debugPrint('🎤 Hotword listener started');
    } on PorcupineException catch (e) {
      debugPrint('🔥 Hotword init error ➜ ${e.message}');
    }
  }

  /// Called when "Jarvis" wake-word detected
  Future<void> _wakeCallback(int _) async {
    try {
      // ⏩ play startup ding
      await _player.play(AssetSource('sounds/start.mp3'));
    } catch (e) {
      debugPrint('🎵 start.mp3 error: $e');
    }

    // ⏬ show bottom Gemini-style overlay
    showOverlay(
      (context, t) => const VoiceOverlay(),
      duration: const Duration(seconds: 12),
    );

    // (Optional) trigger full-screen assistant if needed
    // onWake();
  }

  Future<void> dispose() async {
    await _manager?.stop();
    await _manager?.delete();
    await _player.dispose();
  }
}
