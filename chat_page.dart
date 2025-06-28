
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/model/chat_message.dart';
import 'package:jarvis/services/history_service.dart';
import 'package:jarvis/services/gemini_service.dart';
import 'package:jarvis/controller/settings_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _botTyping = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final hist = await HistoryService.fetchAll();
    setState(() => _messages.addAll(hist));
    _jumpToBottom();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chat', style: TextStyle(color: Colors.white70)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length + (_botTyping ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == _messages.length && _botTyping) {
                    return const _GifTypingIndicator();
                  }
                  final m = _messages[i];
                  final isUser = m.from == Sender.user;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: _ChatBubble(message: m.text, isUser: isUser),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message…',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 23, 18, 66),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white70),
                    onPressed: _handleSend,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();

    final userMsg = ChatMessage(text: text, from: Sender.user);
    setState(() => _messages.add(userMsg));
    HistoryService.add(userMsg);
    _jumpToBottom();

    _getBotReply(text);
  }

  Future<void> _getBotReply(String prompt) async {
    setState(() => _botTyping = true);
    // ignore: unused_local_variable
    final lang = context.read<SettingsController>().voiceLang; // ⬅️ चुनी हुई भाषा

    try {
      final resp = await GeminiService.generate(prompt, context: context, lang: '');
      final botMsg = ChatMessage(text: resp, from: Sender.bot);
      setState(() {
        _botTyping = false;
        _messages.add(botMsg);
      });
      HistoryService.add(botMsg);
      _jumpToBottom();
    } catch (e) {
      setState(() => _botTyping = false);
      final errMsg = ChatMessage(text: '❌ $e', from: Sender.bot);
      setState(() => _messages.add(errMsg));
      HistoryService.add(errMsg);
      _jumpToBottom();
    }
  }

  void _jumpToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isUser});

  final String message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser ? const Color(0xFF4E4AE2) : const Color(0xFF28243D);
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
      ),
      child: _TypewriterText(text: message),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  const _TypewriterText({required this.text});
  final String text;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (_currentIndex >= widget.text.length) {
        _timer.cancel();
      } else {
        setState(() => _currentIndex++);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _currentIndex.clamp(0, widget.text.length)),
      style: const TextStyle(color: Colors.white, height: 1.4),
    );
  }
}

class _GifTypingIndicator extends StatelessWidget {
  const _GifTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.zero,                      // padding हटा दिया
        height: 60,                                    // छोटा box
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF28243D),
          borderRadius: BorderRadius.circular(8),
        ),
        // GIF को box से बड़ा दिखाने के लिए OverflowBox
        child: OverflowBox(
          maxHeight: 120,
          maxWidth: 120,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/gif/load.gif',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}