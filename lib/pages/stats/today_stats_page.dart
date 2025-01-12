import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/live_session.dart';
import 'package:nakime/core/sessions/session_reader.dart';
import 'package:nakime/pages/timeline/timeline_page.dart';

class TodayStatsPage extends StatefulWidget {
  const TodayStatsPage({super.key});

  @override
  State<TodayStatsPage> createState() => _TodayStatsPageState();
}

class _TodayStatsPageState extends State<TodayStatsPage> {
  bool _initialized = false;
  List<Session> _sessions = [];
  VoidCallback? updateLiveTile;
  Timer? liveTileUpdateTimer;

  @override
  void initState() {
    super.initState();
    Future(() async {
      _sessions =
          await SessionReader.readSession(LiveSession.systemStartupTime);
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
      liveTileUpdateTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          updateLiveTile?.call();
        },
      );
    });
  }

  Widget _buildContent() {
    if (_initialized) {
      return _buildInitializedView();
    } else {
      return _buildLoadingView();
    }
  }

  Widget _buildLoadingView() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.onSurface,
          ),
          const Gap(20),
          Text(
            "Loading before your eyes can blink",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600.themed(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Duration _totalIdleTime() {
    Duration result = Duration.zero;
    for (int index = 0; index + 1 < _sessions.length; index++) {
      final previous = _sessions[index];
      final session = _sessions[index + 1];
      final idleTime = session.start.difference(previous.end);
      result += idleTime;
    }
    if (_sessions.isNotEmpty) {
      final idleTime =
          LiveSession.systemStartupTime.difference(_sessions.last.end);
      result += idleTime;
    }
    return result;
  }

  Widget _buildInitializedView() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
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
                  Text(
                    "Session Stats (${LiveSession.systemStartupTime.isSameDay(DateTime.now()) ? "" : "Since "}${DateFormat("EEE, MMM d").format(LiveSession.systemStartupTime)})",
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {

                },
                tooltip: "Export your usage data in excel format",
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Export"),
                    const Gap(4),
                    Icon(
                      Icons.download_rounded,
                      color: AppColors.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(20),
        if (_sessions.isNotEmpty) ...[
          Expanded(
            child: ListView.separated(
              itemCount: _sessions.length + 1,
              separatorBuilder: (context, index) {
                if (index + 1 < _sessions.length) {
                  final previous = _sessions[index];
                  final session = _sessions[index + 1];
                  final idleTime = session.start.difference(previous.end);
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "${idleTime.timeShort} idle",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600.themed(brightness),
                        ),
                      ),
                    ),
                  );
                }
                return const Gap(10);
              },
              itemBuilder: (context, index) {
                if (index == _sessions.length) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            "${LiveSession.systemStartupTime.difference(_sessions.last.end).timeShort} idle",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600.themed(brightness),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            "Total system idle time\n${_totalIdleTime().timeShort}",
                            textAlign: TextAlign.center,
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
                final session = _sessions[index];
                return ListTile(
                  onTap: () {
                    // does nothing as of v1.0.0
                    // the sole purpose of adding this empty callback
                    // is to let the user see on which session entry he is
                    // currently viewing without location the cursor.
                  },
                  splashColor: AppColors.primary.withOpacity(0.1),
                  focusColor: AppColors.primary.withOpacity(0.2),
                  hoverColor: AppColors.primary.withOpacity(0.05),
                  mouseCursor: SystemMouseCursors.basic,
                  title: Text(
                    "Session ${session.id}",
                    style: TextStyle(
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.dayRange,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600.themed(brightness),
                        ),
                      ),
                      Text(
                        session.timeRange,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600.themed(brightness),
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 140,
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          session.time.timeShort,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600.themed(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Once you do more sessions, they will appear here.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
        StatefulBuilder(builder: (context, setSingletonState) {
          final liveSession = Session(
            id: _sessions.length + 1,
            start: LiveSession.systemStartupTime,
            end: DateTime.now(),
          );

          var totalUptime = "0 s";
          var totalTime = Duration.zero;
          if (_sessions.isNotEmpty) {
            totalTime = _sessions.fold(totalTime, (a, b) => a + b.time);
          }
          totalUptime = (totalTime + liveSession.time).timeShort;

          updateLiveTile = () {
            setSingletonState(() {});
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                tileColor: AppColors.primary.withOpacity(0.2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                  ),
                ),
                title: Text(
                  "Live Session",
                  style: TextStyle(
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveSession.dayRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600.themed(brightness),
                      ),
                    ),
                    Text(
                      liveSession.timeRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600.themed(brightness),
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 140,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        liveSession.time.timeShort,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600.themed(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                tileColor: AppColors.primary.withOpacity(0.23),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                title: Text(
                  "Total System Uptime",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const TimelinePage());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outlined,
                          size: 14,
                          color: AppColors.onSurface,
                        ),
                        const Gap(3),
                        Text(
                          "See previous sessions",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600.themed(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                trailing: SizedBox(
                  width: 140,
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalUptime,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600.themed(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _buildContent(),
      ),
    );
  }

  @override
  void dispose() {
    liveTileUpdateTimer?.cancel();
    super.dispose();
  }
}
