import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/session_reader.dart';

class SessionSummaryToday extends StatefulWidget {
  const SessionSummaryToday({
    super.key,
    required this.liveUptime,
  });

  final Duration liveUptime;

  @override
  State<SessionSummaryToday> createState() => _SessionSummaryTodayState();
}

class _SessionSummaryTodayState extends State<SessionSummaryToday> {
  bool _initialized = false;
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      _sessions = await SessionReader.readSession(DateTime.now());
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Reading Sessions",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          const Gap(4),
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              color: AppColors.surface,
            ),
          ),
        ],
      );
    }
    var totalUptime = "0 s";
    if (_sessions.isNotEmpty) {
      final totalTime = _sessions.fold(Duration.zero, (a, b) => a + b.time) + widget.liveUptime;
      totalUptime = totalTime.timeShort;
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final session in _sessions) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Session ${session.id}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  session.time.timeShort,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Session ${_sessions.length + 1}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.liveUptime.timeShort,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Uptime",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                totalUptime,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
