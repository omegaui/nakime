import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:nakime/config/app_animations.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/config/app_icons.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/main.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      "App Info",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 128,
                    child: Lottie.asset(
                      AppAnimations.nakime,
                      repeat: true,
                      reverse: true,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    "Nakime",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    "Installed Version: v${appInfo.version}+${appInfo.buildNumber}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    "Licensed under Apache License 2.0",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See Source Code",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const Gap(100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Clipp extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 90, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
