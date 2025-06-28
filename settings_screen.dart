// lib/screens/weather/settings_screen.dart
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:intl/intl.dart'; // If you need formatted dates later

// You can define these in a shared constants file
const kBgTop = Color(0xFF1E1E2C);
const kCard = Color(0xFF2C2C3A);

// ─── Text Style Helper ────────────────────────────────────────
TextStyle _txt(double size, [FontWeight weight = FontWeight.w600]) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: Colors.white,
  );
}

// ─── Circle Button Widget ─────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: kCard,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────
class WeatherSettingsScreen extends StatelessWidget {
  const WeatherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgTop,
      appBar: AppBar(
        backgroundColor: kBgTop,
        elevation: 0,
        title: Text('सेटिंग्स', style: _txt(20)),
        leading: _CircleBtn(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SettingsTile(
            title: '🌤️ डार्क/लाइट मोड',
            trailing: Switch(value: true, onChanged: null),
          ),
          _SettingsTile(
            title: '🌐 यूनिट्स: °C / °F',
            trailing: Switch(value: true, onChanged: null),
          ),
          _SettingsTile(
            title: '🗺️ लोकेशन परमिशन',
            trailing: Icon(Icons.location_on, color: Colors.white),
          ),
          _SettingsTile(
            title: '🔔 मौसम अलर्ट्स',
            trailing: Switch(value: false, onChanged: null),
          ),
          _SettingsTile(
            title: 'ℹ️ ऐप जानकारी',
            trailing: Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tile Widget ─────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _SettingsTile({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _txt(16)),
          trailing,
        ],
      ),
    );
  }
}