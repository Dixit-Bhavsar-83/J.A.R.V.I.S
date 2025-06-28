import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VoiceType { male, female }
enum WaveStyle { classic, smooth, ios9 }

class SettingsController extends ChangeNotifier {
  int _themeIdx = 0;
  int _gifIdx = 0;
  int _fontIdx = 0;
  int _siriIdx = 0;
  bool _dark = false;
  bool _micAuto = false;
  bool _hotwordEnabled = true;
  String _hotword = "Jarvis";
  String _voiceLang = "English";
  bool _notificationEnabled = true;
  String _defaultPage = "Home";

  VoiceType _voice = VoiceType.female;
  WaveStyle _waveSty = WaveStyle.classic;

  int get themeIdx => _themeIdx;
  int get gifIdx => _gifIdx;
  int get fontIdx => _fontIdx;
  int get siriIdx => _siriIdx;
  bool get darkMode => _dark;
  bool get micAuto => _micAuto;
  bool get hotwordEnabled => _hotwordEnabled;
  String get hotword => _hotword;
  String get voiceLang => _voiceLang;
  bool get notificationEnabled => _notificationEnabled;
  String get defaultPage => _defaultPage;
  VoiceType get voice => _voice;
  WaveStyle get waveStyle => _waveSty;

  static const themeNames = [
    'Midnight Black',
    'Galaxy Blue',
    'Indigo Light',
    'Royal Purple',
    'Teal Glow',
    'Sunset Orange',
    'Pink Neon',
    'Neon Green',
    'only white',
  ];

  static const themeColors = [
    Color(0xFF06022A),
    Colors.indigo,
    Color.fromARGB(255, 235, 235, 235),
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.green
  ];

  static const fontNames = [
    'Poppins',
    'Lobster',
    'Pacifico',
    'Dancing Script',
    'Courgette',
    'Great Vibes',
    'Orbitron',
  ];

  static const siriWaveNames = [
  "Jarvis Core",        // [Blue, White, Red]
  "Cyber Cool",         // [Cyan → CyanAccent]
  "Neon Flame",         // [PinkAccent → Orange]
  "Nature Echo",        // [GreenAccent → Teal]
  "Sunset Rush",        // [DeepOrange → Amber]
  "Indigo Sky",         // [Indigo → LightBlueAccent]
  "Lime Boost",         // [LimeAccent → LightGreen]
  "RGB Strike",         // [Dark Blue → Green Neon]
  "Neon Glow",          // [Hot Pink → Teal]
  "Minty Spark",        // [Mint Green → Salmon]
];

  SettingsController() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _themeIdx = p.getInt('theme') ?? 0;
    _gifIdx = p.getInt('gif') ?? 0;
    _fontIdx = p.getInt('font') ?? 0;
    _siriIdx = p.getInt('siri') ?? 0;
    _dark = p.getBool('dark') ?? false;
    _micAuto = p.getBool('mic') ?? false;
    _hotwordEnabled = p.getBool('hotword_enabled') ?? true;
    _hotword = p.getString('hotword') ?? "Jarvis";
    _voiceLang = p.getString('voice_lang') ?? "English";
    _notificationEnabled = p.getBool('notifications') ?? true;
    _defaultPage = p.getString('default_page') ?? "Home";
    _voice = VoiceType.values[p.getInt('voice') ?? 1];
    _waveSty = WaveStyle.values[p.getInt('wave') ?? 0];
    notifyListeners();
  }

  Future<void> _save(String k, dynamic v) async {
    final p = await SharedPreferences.getInstance();
    switch (v.runtimeType) {
      case int:
        await p.setInt(k, v as int);
        break;
      case bool:
        await p.setBool(k, v as bool);
        break;
      case String:
        await p.setString(k, v as String);
        break;
    }
  }

  void setTheme(int i) {
    _themeIdx = i;
    _save('theme', i);
    notifyListeners();
  }

  void setGif(int i) {
    _gifIdx = i;
    _save('gif', i);
    notifyListeners();
  }

  void setFont(int i) {
    _fontIdx = i;
    _save('font', i);
    notifyListeners();
  }

  void setSiri(int i) {
    _siriIdx = i;
    _save('siri', i);
    notifyListeners();
  }

  void toggleDark() {
    _dark = !_dark;
    _save('dark', _dark);
    notifyListeners();
  }

  void toggleMic() {
    _micAuto = !_micAuto;
    _save('mic', _micAuto);
    notifyListeners();
  }

  void setVoice(VoiceType v) {
    _voice = v;
    _save('voice', v.index);
    notifyListeners();
  }

  void setWaveStyle(WaveStyle w) {
    _waveSty = w;
    _save('wave', w.index);
    notifyListeners();
  }

  void setVoiceLang(String lang) {
    _voiceLang = lang;
    _save('voice_lang', lang);
    notifyListeners();
  }

  void setHotword(String word) {
    _hotword = word;
    _save('hotword', word);
    notifyListeners();
  }

  void toggleHotwordEnabled() {
    _hotwordEnabled = !_hotwordEnabled;
    _save('hotword_enabled', _hotwordEnabled);
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationEnabled = !_notificationEnabled;
    _save('notifications', _notificationEnabled);
    notifyListeners();
  }

  void setDefaultPage(String page) {
    _defaultPage = page;
    _save('default_page', page);
    notifyListeners();
  }
}
