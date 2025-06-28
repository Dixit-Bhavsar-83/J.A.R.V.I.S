import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:jarvis/services/gemini_service.dart';

void showAssistantOverlay(BuildContext ctx) => showGeneralDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black87.withOpacity(.8),
      pageBuilder: (_, __, ___) => const _Assistant(),
    );

class _Assistant extends StatefulWidget {
  const _Assistant();

  @override
  State<_Assistant> createState() => _AssistantState();
}

class _AssistantState extends State<_Assistant> {
  final _speech = SpeechToText();
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  String _user = '', _bot = '';
  bool _listen = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _player.play(AssetSource('sounds/start.mp3'));
    await _speech.initialize();
    _speech.listen(onResult: (r) async {
      setState(() => _user = r.recognizedWords);
      if (r.finalResult) {
        _speech.stop();
        setState(() => _listen = false);
        final resp = await GeminiService.generate(_user, lang: '');
        if (!mounted) return;
        setState(() => _bot = resp);
        await _tts.speak(resp);
      }
    });
    setState(() => _listen = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('assets/gif/6.gif', height: 350),
            const SizedBox(height: 100),
            Text(
              _bot.isEmpty
                  ? (_user.isEmpty
                      ? (_listen ? 'Listening…' : 'Processing…')
                      : _user)
                  : _bot,
              style:
                  const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30))
          ]),
        ),
      );

  @override
  void dispose() {
    _speech.stop();
    _player.dispose();
    _tts.stop();
    super.dispose();
  }
}
