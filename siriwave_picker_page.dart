import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/controller/settings_controller.dart';

class SiriWavePickerPage extends StatelessWidget {
  const SiriWavePickerPage({super.key});

 /* new colours add and one by one set colourfist and last */
static const _previewColors = [
  [Color.fromARGB(255, 11, 0, 161), Color.fromARGB(255, 255, 0, 0)], // Jarvis Core
  [Colors.cyan, Colors.cyanAccent],                                 // Cyber Cool
  [Colors.pinkAccent, Colors.orange],                               // Neon Flame
  [Colors.greenAccent, Colors.teal],                                // Nature Echo
  [Colors.deepOrange, Colors.amber],                                // Sunset Rush
  [Colors.indigo, Colors.lightBlueAccent],                          // Indigo Sky
  [Colors.limeAccent, Colors.lightGreen],                           // Lime Boost
  [Color(0xFF000284), Color(0xFF84F800)],                           // RGB Strike
  [Color(0xFFFF6EC7), Color(0xFF2CE0BF)],                           // Neon Glow
  [Color(0xFF3EECAC), Color(0xFFFFA07A)],                           // Minty Spark
];
 

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 2, 42),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('SiriWave Style'),
      ),
      body: ListView.builder(
        itemCount: SettingsController.siriWaveNames.length,
        itemBuilder: (_, i) {
          final selected = s.siriIdx == i;
          final colors = _previewColors[i % _previewColors.length];
          return ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: colors
                  .map((c) => Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      ))
                  .toList(),
            ),
            title: Text(SettingsController.siriWaveNames[i],
                style: const TextStyle(color: Colors.white)),
            trailing: selected
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                : null,
            onTap: () => s.setSiri(i),
          );
        },
      ),
    );
  }
}
