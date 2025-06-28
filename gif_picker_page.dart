import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/settings_controller.dart';

class GifPickerPage extends StatelessWidget {
  const GifPickerPage({super.key});

  static const _gifNames = [
    'NeoBot',
    'Zeno',
    'Orbit',
    'Nexie',
    'Cosmo',
    'Jarvito',
    'Jarvis',
    'Shifra',
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFF06022A),
      appBar: AppBar(
        title: const Text('Select GIF Avatar'),
        backgroundColor: const Color(0xFF06022A),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8, // overflow fix
        ),
        itemCount: _gifNames.length,
        itemBuilder: (context, index) {
          final selected = s.gifIdx == index;
          return GestureDetector(
            onTap: () => s.setGif(index),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? Colors.greenAccent
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/gif/$index.gif', // ← 0.gif-7.gif
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _gifNames[index],
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
