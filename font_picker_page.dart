import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/settings_controller.dart';

class FontPickerPage extends StatelessWidget {
  const FontPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    final fontMap = {
      'Poppins': GoogleFonts.poppins,
      'Lobster': GoogleFonts.lobster,
      'Pacifico': GoogleFonts.pacifico,
      'Dancing Script': GoogleFonts.dancingScript,
      'Courgette': GoogleFonts.courgette,
      'Great Vibes': GoogleFonts.greatVibes,
      'Orbitron': GoogleFonts.orbitron,
    };

    return Scaffold(
      backgroundColor: const Color(0xFF06022A),
      appBar: AppBar(title: const Text('Choose Font')),
      body: ListView.builder(
        itemCount: SettingsController.fontNames.length,
        itemBuilder: (_, index) {
          final name = SettingsController.fontNames[index];
          final selected = s.fontIdx == index;
          return ListTile(
            title: Text('Sample AaBbCc',
                style: fontMap[name]!(fontSize: 20, color: Colors.white)),
            subtitle: Text(name, style: const TextStyle(color: Colors.white54)),
            trailing:
                selected ? const Icon(Icons.check_circle, color: Colors.greenAccent) : null,
            onTap: () => s.setFont(index),
          );
        },
      ),
    );
  }
}
