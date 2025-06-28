// 🟣 lib/pages/jarvis.dart — Listen‑screen logic v4
//  • Continuous SiriWave animation (theme‑coloured)
//  • Tap on any home icon plays start.mp3 before navigation
//  • Settings integration: theme GIF, male/female TTS voice, SiriWave colour
//  • Auto‑listen, 10‑s idle back‑home, reply in 3‑line chunks
//  • History stored via HistoryService

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:jarvis/controller/speech_controller.dart';
import 'package:jarvis/controller/waveform_controller.dart';
import 'package:jarvis/controller/settings_controller.dart';
import 'package:jarvis/model/chat_message.dart';
import 'package:jarvis/pages/chat_page.dart';
import 'package:jarvis/pages/history_page.dart';
import 'package:jarvis/pages/settings_page.dart';
import 'package:jarvis/services/gemini_service.dart';
import 'package:jarvis/services/history_service.dart';

class Jarvis extends StatefulWidget {
  const Jarvis({super.key});

  @override
  State<Jarvis> createState() => _JarvisState();
}

class _JarvisState extends State<Jarvis> {
  bool isHome = true; // true → home, false → listen
  String aiText = '';
  final FlutterTts _tts = FlutterTts();
  Timer? _idleTimer; // 10‑sec idle timer

  /* ───────── helpers ───────── */
  Future<void> _playTapSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/start.mp3'));
  }

  List<String> _threeLineChunks(String text) {
    const maxChars = 180;
    final words = text.split(RegExp(r'\s+'));
    final List<String> out = [];
    var buf = StringBuffer();
    for (final w in words) {
      if (buf.length + w.length + 1 > maxChars) {
        out.add(buf.toString().trim());
        buf = StringBuffer();
      }
      buf.write('$w ');
    }
    if (buf.isNotEmpty) out.add(buf.toString().trim());
    return out;
  }

  void _stopAll(SpeechController sc) {
    _idleTimer?.cancel();
    _tts.stop();
    sc.stopListening();
    sc.reset();
    aiText = '';
  }

  /* ───────── session start ───────── */
  void _startSession(SpeechController sc) {
    _stopAll(sc);
    setState(() => isHome = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _beginListening(sc));
  }

  /* ───────── listening control ───────── */
  void _beginListening(SpeechController sc) {
    sc.startListening();
    setState(() => aiText = '');
    _resetIdleTimer(sc);
  }

  void _resetIdleTimer(SpeechController sc) {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !sc.hasText && !sc.isListening) _backHome(sc);
    });
  }

  /* ───────── AI reply ───────── */
  Future<void> _replyAndResume(SpeechController sc) async {
    final user = sc.lastWords.trim();
    if (user.isEmpty) return;

    await HistoryService.add(ChatMessage(text: user, from: Sender.user));
    setState(() => aiText = '');

    try {
      var reply = await GeminiService.generate(user, lang: '');
      reply = reply
          .replaceAll(RegExp(r'\*\*'), '')
          .replaceAll(RegExp(r'```(?:[a-z]*)?'), '')
          .replaceAll('```', '')
          .replaceAll('`', '');

      final chunks = _threeLineChunks(reply);
      await HistoryService.add(ChatMessage(text: reply, from: Sender.bot));

      if (!mounted) return;
      setState(() => aiText = reply);

      // Apply voice gender from settings
      final settings = context.read<SettingsController>();
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      if (settings.voice == VoiceType.male) {
        await _tts.setVoice({
          'name': 'en-us-x-sfg#male_1-local',
          'locale': 'en-US',
        });
      } else {
        await _tts.setVoice({
          'name': 'en-us-x-sfg#female_1-local',
          'locale': 'en-US',
        });
      }

      for (final c in chunks) {
        await _tts.speak(c);
        await _tts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => aiText = '⚠️ $e');
    } finally {
      if (mounted) _beginListening(sc); // listen again
    }
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    final sc = Provider.of<SpeechController>(context);

    // Listening / reply trigger logic
    if (!isHome) {
      if (!sc.isListening && sc.lastWords.isEmpty) {
        _beginListening(sc);
      } else if (!sc.isListening && sc.lastWords.isNotEmpty && aiText.isEmpty) {
        _replyAndResume(sc);
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      body: SafeArea(child: isHome ? _home(sc) : _listen(sc)),
    );
  }

  /* Home */
  Widget _home(SpeechController sc) {
    // Dynamic assets & fonts from settings
    final settings = context.watch<SettingsController>();
    final gifPath = 'assets/gif/${settings.gifIdx}.gif';


    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text('Hi 👋, Dixit Bhavsar83',
              style: GoogleFonts.shareTech(
                  color: Colors.cyan, fontSize: 16, letterSpacing: .5)),
          const SizedBox(height: 20),
          Text('How can I help you',
              style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 24)),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () async {
              await _playTapSound();
              _startSession(sc);
            },
            child: Image.asset(gifPath, height: 350),
          ),
          TextAnimatorSequence(loop: true, children: [
            TextAnimator('J . A . R . V . I . S',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                atRestEffect: WidgetRestingEffects.pulse())
          ]),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _homeIcon(Icons.mic_none, 'Mic', () async {
              await _playTapSound();
              _startSession(sc);
            }),
            _homeIcon(Icons.chat, 'Chat', () async {
              await _playTapSound();
              _stopAll(sc);
               // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
            }),
            _homeIcon(Icons.history, 'History', () async {
              await _playTapSound();
              _stopAll(sc);
               // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            }),
            _homeIcon(Icons.settings, 'Settings', () async {
              await _playTapSound();
              _stopAll(sc);
              // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            }),
          ])
        ],
      ),
    );
  }

  Widget _homeIcon(IconData i, String label, VoidCallback tap) => GestureDetector(
        onTap: tap,
        child: Column(children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24)),
              child: Icon(i, color: Colors.white70, size: 32)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))
        ]),
      );

  /* Listen */
  Widget _listen(SpeechController sc) => Stack(children: [
        Column(children: [
          const SizedBox(height: 90),
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: aiText.isEmpty
                    ? Text(sc.lastWords,
                        style: const TextStyle(color: Colors.white, fontSize: 18))
                    : AnimatedTextKit(
                        isRepeatingAnimation: false,
                        animatedTexts: _threeLineChunks(aiText)
                            .map((c) => FadeAnimatedText(
                                  c,
                                  textAlign: TextAlign.left,
                                  textStyle: const TextStyle(color: Colors.white, fontSize: 18),
                                  duration: const Duration(milliseconds: 1200),
                                ))
                            .toList(),
                      ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 120,
            child: SiriWaveform.ios9(
              controller: WaveformController(context).controller,
              options: const IOS9SiriWaveformOptions(height: 120, width: 400),
            ),
          ),
          const SizedBox(height: 24),
        ]),
        Positioned(
          top: 10,
          left: 4,
          child: Row(children: [
            IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => _backHome(sc)),
            const SizedBox(width: 4),
            const Text('AI Assistant',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ]),
        )
      ]);

  void _backHome(SpeechController sc) {
    setState(() => isHome = true);
    _stopAll(sc);
  }
}
