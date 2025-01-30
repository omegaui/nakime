import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/constants/service_constants.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/live_session_state_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/live_session.dart';
import 'package:nakime/core/sessions/session_health_checks.dart';
import 'package:nakime/pages/help/help_page.dart';
import 'package:nakime/pages/info/app_info_page.dart';
import 'package:nakime/pages/stats/today_stats_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? realTimeSessionTimer;
  Duration elapsed = Duration.zero;

  @override
  void initState() {
    computeElapsed();
    if (LiveSession.state.isStable) {
      realTimeSessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (mounted) {
            computeElapsed();
            setState(() {});
          }
        },
      );
    }
    super.initState();
  }

  void computeElapsed() {
    final now = DateTime.now();
    elapsed = now.difference(LiveSession.systemStartupTime);
  }

  Widget _buildContent() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    if (LiveSession.state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_outlined,
                color: Colors.grey.shade800,
                size: 128,
              ),
              const Text(
                "Background Service is inactive",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              const Text(
                "Please open \"Services\", and check if \"NakimeWindowsService\" is running, if it's not running then, please either start it manually or do a system restart.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (LiveSession.state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.grey.shade800,
                size: 128,
              ),
              const Text(
                "Broken Installation Detected",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              const Text(
                "Please make sure \"NakimeWindowsService\" is installed correctly and is active in the background. This can be confirmed by checking if \"Services\" application has Nakime's Windows Service entry in the services list. For any help please click on Help button provided on top right corner of this window.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            elapsed.time,
            style: const TextStyle(
              fontSize: 32,
            ),
          ),
          const Text(
            "Session Uptime",
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          const Gap(4),
          TextButton(
            onPressed: () {
              Get.to(() => const TodayStatsPage());
            },
            child: Text(
              "View Stats",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600.themed(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildContent(),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.to(() => const HelpPage());
                      },
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Help"),
                          const Gap(4),
                          Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    IconButton(
                      onPressed: () {
                        Get.to(() => const AppInfoPage());
                      },
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("App Info"),
                          const Gap(4),
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: FutureBuilder(
                future: SessionHealthChecks.errorCount(),
                builder: (context, snapshot) {
                  if (snapshot.data == null || snapshot.data == 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 250,
                      child: Tooltip(
                        message:
                            "Please report the errors on GitHub (click to open log folder)",
                        child: ListTile(
                          onTap: () {
                            launchUrlString(ServiceConstants.errorLogsDir);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          leading: Icon(
                            Icons.warning_amber_outlined,
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                          title: Text(
                            "${snapshot.data} Errors encountered",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            "attention needed",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    realTimeSessionTimer?.cancel();
    super.dispose();
  }
}
