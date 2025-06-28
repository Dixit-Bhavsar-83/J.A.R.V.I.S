// lib/screens/start_screen.dart
// ignore_for_file: use_super_parameters

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../controller/settings_controller.dart';
import '../pages/jarvis.dart'; // <-- JARVIS main screen

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final FlutterTts _tts = FlutterTts();

  bool _showGif = true;

  final List<String> _lines = [
    'Hello, Dixit',
    'Welcome Boss',
    'Now me to introduce myself',
    'I am JARVIS.',
    'A virtual assistant',
    'Importing all the preferences',
    'System is now fully operational',
  ];

  int _currentIndex = 0;
  String _currentText = '';
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _tts
      ..setSpeechRate(0.45) // 🔉 TTS speed: Normal/Medium-fast
      ..setPitch(1.0)
      ..awaitSpeakCompletion(true);

    // 5 seconds GIF → then text animation
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showGif = false);
      _playNextLine();
    });
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _playNextLine() async {
    if (_currentIndex >= _lines.length) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Jarvis()),
      );
      return;
    }

    _currentText = _lines[_currentIndex];
    setState(() => _visible = true); // Fade-in
    await _speak(_currentText);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _visible = false); // Fade-out
    await Future.delayed(const Duration(milliseconds: 300));

    _currentIndex++;
    _playNextLine();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final bgColor = SettingsController.themeColors[settings.themeIdx];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1️⃣ GIF Splash (centered)
          if (_showGif)
            Center(
              child: Image.asset(
                'assets/gif/6.gif',
                height: 750,
              ),
            ),

          // 2️⃣ Centered animated text lines
          if (!_showGif)
            Center(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _currentText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
