import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:google_fonts/google_fonts.dart';

// Controllers
import 'controller/speech_controller.dart';
import 'controller/settings_controller.dart';

// Screens
import 'pages/jarvis.dart';
import 'pages/font_picker_page.dart';
import 'pages/gif_picker_page.dart';
import 'pages/settings_page.dart';
import 'pages/theme_picker_page.dart';
import 'pages/voice_picker_page.dart';
import 'pages/siriwave_picker_page.dart';
import 'pages/start_screen.dart'; // 👈 New screen import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsController()),
          ChangeNotifierProvider(create: (_) => SpeechController()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    final fontGetters = [
      GoogleFonts.poppinsTextTheme,
      GoogleFonts.lobsterTextTheme,
      GoogleFonts.pacificoTextTheme,
      GoogleFonts.dancingScriptTextTheme,
      GoogleFonts.courgetteTextTheme,
      GoogleFonts.greatVibesTextTheme,
      GoogleFonts.orbitronTextTheme,
    ];

    final base = ThemeData(
      brightness: s.darkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SettingsController.themeColors[s.themeIdx],
        brightness: s.darkMode ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor:
          s.darkMode ? const Color(0xFF121212) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: s.darkMode ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: s.darkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: fontGetters[s.fontIdx](
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: s.darkMode ? Colors.white : Colors.black,
        displayColor: s.darkMode ? Colors.white : Colors.black,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base,
      // 👇 Update to open StartScreen first
      home: const StartScreen(),
      routes: {
        '/settings': (_) => const SettingsPage(),
        '/gif-select': (_) => const GifPickerPage(),
        '/font-select': (_) => const FontPickerPage(),
        '/theme-select': (_) => const ThemePickerPage(),
        '/voice-select': (_) => const VoicePickerPage(),
        '/siriwave-select': (_) => const SiriWavePickerPage(),
      },
    );
  }
}
