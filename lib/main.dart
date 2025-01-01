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
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    dark: false,
  );
  await LiveSession.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Nakime",
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(context, Brightness.light),
      home: const HomePage(),
      defaultTransition: Transition.leftToRight,
      transitionDuration: Duration.zero,
    );
  }
}

ThemeData _buildTheme(BuildContext context, Brightness brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.surface,
      ),
    ),
  );
}
