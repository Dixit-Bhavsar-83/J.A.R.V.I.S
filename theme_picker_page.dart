import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/controller/settings_controller.dart';

class ThemePickerPage extends StatelessWidget {
  const ThemePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final colors = SettingsController.themeColors;
    final names = SettingsController.themeNames;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Theme"),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      body: ListView.builder(
        itemCount: colors.length,
        itemBuilder: (_, i) {
          final selected = s.themeIdx == i;
          return ListTile(
            leading: CircleAvatar(backgroundColor: colors[i]),
            title: Text(names[i], style: const TextStyle(color: Colors.white)),
            trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () => s.setTheme(i),
          );
        },
      ),
    );
  }
}
