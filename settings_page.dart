// ╭──────────────────────────────────────────────────────────────────────────────╮
// │  lib/pages/settings_page.dart — FINAL FIXED with Weather Integration        │
// ╰──────────────────────────────────────────────────────────────────────────────╯

import 'package:flutter/material.dart';
import 'package:jarvis/pages/weather/weather_ui.dart' show WeatherHomeScreen;
import 'package:provider/provider.dart';
import 'package:jarvis/controller/settings_controller.dart';
import 'package:jarvis/pages/theme_picker_page.dart';
import 'package:jarvis/pages/gif_picker_page.dart';
import 'package:jarvis/pages/font_picker_page.dart';
import 'package:jarvis/pages/siriwave_picker_page.dart';
import 'package:jarvis/pages/about_page.dart';
import 'package:jarvis/pages/weather/weather_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white70)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Appearance ────────────────────────────────────────────────────
          _header('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.white70),
            title: const Text('Theme'),
            subtitle: Text(SettingsController.themeNames[s.themeIdx]),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ThemePickerPage())),
          ),
          ListTile(
            leading: const Icon(Icons.gif_box_rounded, color: Colors.white70),
            title: const Text('Jarvis GIF'),
            subtitle: Text(_getGifName(s.gifIdx)),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const GifPickerPage())),
          ),
          ListTile(
            leading: const Icon(Icons.font_download, color: Colors.white70),
            title: const Text('Font Style'),
            subtitle: Text(SettingsController.fontNames[s.fontIdx]),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const FontPickerPage())),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: s.darkMode,
            onChanged: (_) => s.toggleDark(),
            secondary: const Icon(Icons.dark_mode, color: Colors.white70),
          ),
          const Divider(color: Colors.white24),

          // ─── Voice & Wave ──────────────────────────────────────────────────
          _header('Voice & Wave'),
          Column(
            children: VoiceType.values.map((v) {
              final isSelected = s.voice == v;
              return RadioListTile<VoiceType>(
                value: v,
                groupValue: s.voice,
                onChanged: (val) => s.setVoice(val!),
                title: Text(v == VoiceType.male ? 'Male Voice' : 'Female Voice'),
                selected: isSelected,
                activeColor: Colors.greenAccent,
              );
            }).toList(),
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq, color: Colors.white70),
            title: const Text('SiriWave Style'),
            subtitle: Text(SettingsController.siriWaveNames[s.siriIdx]),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SiriWavePickerPage())),
          ),
          SwitchListTile(
            title: const Text('Mic Auto‑Start'),
            value: s.micAuto,
            onChanged: (_) => s.toggleMic(),
            secondary: const Icon(Icons.mic, color: Colors.white70),
          ),
          SwitchListTile(
            title: const Text('Sound Feedback'),
            value: s.notificationEnabled,
            onChanged: (_) => s.toggleNotifications(),
            secondary: const Icon(Icons.volume_up, color: Colors.white70),
          ),
          const Divider(color: Colors.white24),

          // ─── Language ─────────────────────────────────────────────────────
          _header('Language'),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white70),
            title: const Text('AI Response Language'),
            subtitle: Text(s.voiceLang),
            trailing: DropdownButton<String>(
              value: s.voiceLang,
              underline: const SizedBox.shrink(),
              dropdownColor: const Color(0xFF1C1B33),
              onChanged: (v) => s.setVoiceLang(v!),
              items: ['English', 'Hindi', 'Gujarati']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
            ),
          ),

          const Divider(color: Colors.white24),

          // ─── Weather ─────────────────────────────────────────────────────
          _header('Weather'),
          ListTile(
            leading: const Icon(Icons.cloud, color: Colors.white70),
            title: const Text('Check Weather'),
            subtitle: const Text('Live temperature & forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherHomeScreen()),
              );
            },
          ),

          const Divider(color: Colors.white24),

          // ─── Misc ─────────────────────────────────────────────────────────
          _header('Misc'),
          SwitchListTile(
            title: const Text('Hotword "Jarvis"'),
            value: s.hotwordEnabled,
            onChanged: (_) => s.toggleHotwordEnabled(),
            secondary: const Icon(Icons.hearing, color: Colors.white70),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white70),
            title: const Text('About'),
            subtitle: const Text('App & Developer info'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AboutPage())),
          ),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      );

  String _getGifName(int index) {
    const names = [
      'NeoBot',
      'Zeno',
      'Orbit',
      'Nexie',
      'Cosmo',
      'Jarvito'
    ];
    return names.asMap().containsKey(index) ? names[index] : 'GIF \${index + 1}';
  }
}
