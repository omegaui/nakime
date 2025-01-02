import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/sessions/live_session.dart';
import 'package:nakime/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await LiveSession.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _initWindow = false;

  Future<void> initWindow(Brightness brightness) async {
    if(!_initWindow) {
      _initWindow = true;
      final isDarkMode = brightness == Brightness.dark;
      await Window.setEffect(
        effect: isDarkMode ? WindowEffect.mica : WindowEffect.hudWindow,
        dark: isDarkMode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    initWindow(brightness);
    return GetMaterialApp(
      title: "Nakime",
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(context, brightness),
      home: const HomePage(),
      defaultTransition: Transition.leftToRight,
      transitionDuration: Duration.zero,
    );
  }
}

ThemeData _buildTheme(BuildContext context, Brightness brightness) {
  var baseTheme = ThemeData(brightness: brightness);
  final isDarkMode = brightness == Brightness.dark;

  return baseTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? Colors.white : AppColors.surface,
      ),
    ),
  );
}
