import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/live_session.dart';
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
  bool _shownSmoothAnimation = false;

  List<Color> gradientColors = [
    Colors.grey.shade700,
    Colors.grey.shade900,
  ];

  @override
  void initState() {
    super.initState();
    Future(() async {
      _sessions = await SessionReader.readSession(DateTime.now());
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        Future.delayed(
          const Duration(milliseconds: 500),
          () {},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    if (!_initialized || !_shownSmoothAnimation) {
      if (!_shownSmoothAnimation) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            setState(() {
              _shownSmoothAnimation = true;
            });
          },
        );
      }
      if(!_shownSmoothAnimation) {
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(100),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(18),
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
    var totalTime = Duration.zero;
    if (_sessions.isNotEmpty) {
      totalTime = _sessions.fold(totalTime, (a, b) => a + b.time);
    }
    totalUptime = (totalTime + widget.liveUptime).timeShort;
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
                Text(
                  session.time.timeShort,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
              ],
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "This Session",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600.themed(brightness),
                ),
              ),
              Text(
                widget.liveUptime.timeShort,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600.themed(brightness),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Uptime",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600.themed(brightness),
                ),
              ),
              Text(
                totalUptime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600.themed(brightness),
                ),
              ),
            ],
          ),
          const Gap(10),
          if(_sessions.isNotEmpty) ... [
            Text(
              "Gap b/w last & current session\n${LiveSession.systemStartupTime.difference(_sessions.last.end).timeShort}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600.themed(brightness),
              ),
            ),
          ] else ... [
            Text(
              "This is today's first session",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600.themed(brightness),
              ),
            ),
            const Gap(5),
          ],
          TextButton(
            onPressed: () {

            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                ),
                const Gap(4),
                Text(
                  "View Previous Sessions",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
