import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/controller/settings_controller.dart';

class VoicePickerPage extends StatelessWidget {
  const VoicePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Voice"),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      body: Column(
        children: VoiceType.values.map((v) {
          final selected = s.voice == v;
          return ListTile(
            leading: Icon(v == VoiceType.male ? Icons.male : Icons.female, color: Colors.white),
            title: Text(v == VoiceType.male ? "Male" : "Female", style: const TextStyle(color: Colors.white)),
            trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () => s.setVoice(v),
          );
        }).toList(),
      ),
    );
  }
}
