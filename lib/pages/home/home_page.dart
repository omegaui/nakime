import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nakime/core/extensions/live_session_state_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/live_session.dart';
import 'package:nakime/pages/home/widgets/session_summary_today.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? realTimeSessionTimer;
  Duration elapsed = Duration.zero;

  bool _showMoreStats = false;

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
    if (LiveSession.state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_rounded,
                color: Colors.grey.shade800,
                size: 64,
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.grey.shade800,
                size: 64,
              ),
              const Text(
                "Broken Installation Detected",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              const Text(
                "Please make sure \"NakimeWindowsService\" is installed correctly and is active in the background. This can be confirmed by checking if \"Services\" application has Nakime's Windows Service entry in the services list.",
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
          Gap(_showMoreStats ? 20 : 4),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: _showMoreStats
                ? LimitedBox(
                    maxWidth: 200,
                    maxHeight: 180,
                    child: SizedBox(
                      width: 200,
                      child: SessionSummaryToday(
                        liveUptime: elapsed,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          Gap(_showMoreStats ? 20 : 4),
          TextButton(
            onPressed: () {
              setState(() {
                _showMoreStats = !_showMoreStats;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showMoreStats ? "Collapse" : "See More",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _showMoreStats
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
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
      body: _buildContent(),
    );
  }

  @override
  void dispose() {
    realTimeSessionTimer?.cancel();
    super.dispose();
  }
}
