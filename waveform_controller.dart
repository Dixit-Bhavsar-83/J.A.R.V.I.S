// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:jarvis/controller/settings_controller.dart';

class WaveformController {
  late final IOS9SiriWaveformController controller;

  WaveformController(BuildContext ctx) {
    final idx = ctx.read<SettingsController>().siriIdx;
    final palette = [
     [const Color.fromARGB(255, 11, 0, 161), const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 0, 0)], // Original vibrant
  [Colors.cyan, Colors.blueAccent, Colors.cyanAccent],                             // Cool blue
  [Colors.pinkAccent, Colors.purpleAccent, Colors.orange],                         // Energetic
  [Colors.greenAccent, Colors.green, Colors.teal],                                 // Nature green
  [Colors.deepOrange, Colors.orange, Colors.amber],                                // Warm sunset
  [Colors.indigo, Colors.blue, Colors.lightBlueAccent],                            // Indigo wave
  [Colors.limeAccent, Colors.lime, Colors.lightGreen],                             // Fresh lime
  [Color(0xFF000284), Color(0xFFF50000), Color(0xFF84F800)],                       // Jarvis RGB style
  [Color(0xFFFF6EC7), Color(0xFF733DFF), Color(0xFF2CE0BF)],                       // Neon pink/teal/purple
  [Color(0xFF3EECAC), Color(0xFFEE74E1), Color(0xFFFFA07A)],  
    ][idx];

    controller = IOS9SiriWaveformController(
      amplitude: 0.9,
      speed: 0.15,
      color1: palette[0],
      color2: palette[1],
      color3: palette[2],
    );
  }
}
