import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:nakime/config/app_animations.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extras.dart';
import 'package:nakime/main.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
                IconButton(
                  onPressed: () {},
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Check for updates"),
                      const Gap(4),
                      Icon(
                        Icons.update,
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 14,
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
                          onPressed: () {
                            launchUrlString(
                              'https://github.com/omegaui/nakime',
                            );
                          },
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
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FutureBuilder(
                        future: isUptimeInstalled(),
                        builder: (context, snapshot) {
                          if (!(snapshot.data ?? false)) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Did you know?",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 80.0,
                                    ),
                                    child: Text(
                                      "Nakime also has a command line version called 'uptime', which you can use directly from your windows terminal.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      launchUrlString(
                                          "https://github.com/omegaui/uptime");
                                    },
                                    icon: Text(
                                      "Check out uptime on GitHub",
                                      style: TextStyle(
                                        color: AppColors.onSurface
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
