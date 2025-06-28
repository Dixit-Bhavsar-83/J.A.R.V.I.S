import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/chat_message.dart';

class HistoryService {
  static const _key = 'jarvis_history';
  static const _maxItems = 100; // 🌟 100 मैसेज तक रखें

  static Future<void> add(ChatMessage m) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];

    // नया मैसेज add करें
    list.add(jsonEncode(m.toJson()));

    // पुराना overflow हटाएँ
    if (list.length > _maxItems) {
      list.removeRange(0, list.length - _maxItems);
    }

    await sp.setStringList(_key, list);
  }

  static Future<List<ChatMessage>> fetchAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? [];
    return raw
        .map((e) => ChatMessage.fromJson(jsonDecode(e)))
        .toList(growable: false);
  }

  // नया delete–specific (History पैनल के लिये)
  static Future<void> delete(ChatMessage m) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? [];
    list.remove(jsonEncode(m.toJson()));
    await sp.setStringList(_key, list);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
