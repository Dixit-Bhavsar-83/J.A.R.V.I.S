import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jarvis/controller/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyDTpQEh3zaz9V0-ZbHLH0y_3Y86reYCfPk';
  static const _modelId = 'gemini-1.5-flash';

  static Future<String> generate(String prompt, {BuildContext? context, int retries = 1, required String lang}) async {
    String languagePrefix = '';
    
    // 🗣️ Add language instruction only if context is provided
    if (context != null) {
      final lang = context.read<SettingsController>().voiceLang;
      if (lang == "Hindi") {
        languagePrefix = "Reply in Hindi: ";
      } else if (lang == "Gujarati") {
        languagePrefix = "Reply in Gujarati: ";
      } // English: no prefix needed
    }

    final fullPrompt = "$languagePrefix$prompt";

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": fullPrompt}
          ]
        }
      ]
    });

    final res = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final candidates = (data['candidates'] as List?) ?? [];
      final parts = (candidates.first['content']['parts'] as List?) ?? [];
      return (parts.first['text'] ?? '').toString().replaceAll(RegExp(r'\*\*'), '').trim();
    }

    if (res.statusCode == 429 && retries > 0) {
      await Future.delayed(const Duration(seconds: 50));
      // ignore: use_build_context_synchronously
      return generate(prompt, context: context, retries: retries - 1, lang: '');
    }

    throw Exception('Gemini error ${res.statusCode}: ${res.reasonPhrase}\n${res.body}');
  }
}
