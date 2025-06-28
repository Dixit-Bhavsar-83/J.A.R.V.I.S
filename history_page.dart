import 'package:flutter/material.dart';
import 'package:jarvis/model/chat_message.dart';
import 'package:jarvis/services/history_service.dart';
import 'package:flutter/services.dart';   // ← Clipboard के लिये


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ChatMessage> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _history = await HistoryService.fetchAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('History', style: TextStyle(color: Colors.white70)),
        actions: [
          IconButton(
              onPressed: () async {
                await HistoryService.clear();
                _load();
              },
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent))
        ],
      ),
      body: _history.isEmpty
          ? const Center(
              child: Text('No history yet',
                  style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _history.length,
              itemBuilder: (_, i) {
                final m = _history[i];
                final isUser = m.from == Sender.user;
                final icon =
                    isUser ? Icons.person : Icons.smart_toy_outlined;
                return Dismissible(
                  key: ValueKey('${m.time}${m.text}'),
                  onDismissed: (_) async {
                    await HistoryService.delete(m);
                    _load();
                  },
                  background: Container(color: Colors.redAccent),
                  child: ListTile(
                    leading: Icon(icon,
                        color: isUser ? Colors.cyan : Colors.amber),
                    title: Text(
                      m.text,
                      style: const TextStyle(
                          color: Colors.white, height: 1.4, fontSize: 14),
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.copy,
                            color: Colors.white38, size: 18),
                        onPressed: () => Clipboard.setData(
                            ClipboardData(text: m.text))),
                  ),
                );
              },
            ),
    );
  }
}
