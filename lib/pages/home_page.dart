import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nakime/core/extensions/live_session_state_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/live_session.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
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
            IconButton(
              onPressed: () {

              },
              tooltip: "More Info",
              icon: const Icon(
                Icons.info_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    realTimeSessionTimer?.cancel();
    super.dispose();
  }
}
