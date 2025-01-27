import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/extras.dart';
import 'package:nakime/core/sessions/session_reader.dart';
import 'package:nakime/pages/info/session_tag_info_page.dart';

enum _ChartType {
  line,
  smooth,
  step,
}

extension _ChartTypeExtension on _ChartType {
  String get displayName {
    switch (this) {
      case _ChartType.line:
        return "Line Chart";
      case _ChartType.smooth:
        return "Smooth Chart";
      case _ChartType.step:
        return "Step Chart";
    }
  }

  _ChartType get next {
    switch (this) {
      case _ChartType.line:
        return _ChartType.smooth;
      case _ChartType.smooth:
        return _ChartType.step;
      case _ChartType.step:
        return _ChartType.line;
    }
  }

  IconData get iconData {
    switch (this) {
      case _ChartType.line:
        return Icons.line_axis;
      case _ChartType.smooth:
        return Icons.bar_chart;
      case _ChartType.step:
        return Icons.show_chart;
    }
  }
}

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _now = DateTime.now();
  DateTime? _startTime;
  DateTime? _endTime;
  String _pickerMode = "start-date";
  bool _showPicker = false;
  bool _hideControls = false;

  TimelineReadResult? result;
  bool _searchInProgress = false;

  _ChartType _chartType = _ChartType.line;

  final _scrollController = ScrollController();
  bool _showGoToTopButton = false;

  @override
  void initState() {
    _scrollController.addListener(
      () {
        if (_scrollController.offset > 100) {
          if (!_showGoToTopButton) {
            setState(() {
              _showGoToTopButton = true;
            });
          }
        } else {
          if (_showGoToTopButton) {
            setState(() {
              _showGoToTopButton = false;
            });
          }
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
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
                            const Text(
                              "See Previous Sessions",
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        if (result != null && result!.data.isNotEmpty) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _chartType = _chartType.next;
                                  });
                                },
                                tooltip:
                                    "Click to change to ${_chartType.next.displayName}",
                                icon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _chartType.displayName,
                                    ),
                                    const Gap(4),
                                    Icon(
                                      _chartType.iconData,
                                      color: AppColors.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(10),
                              IconButton(
                                onPressed: () {},
                                tooltip:
                                    "Export your usage data in excel format",
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
                        ],
                      ],
                    ),
                  ),
                  if (result != null && result!.data.isNotEmpty) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(40),
                            SizedBox(
                              height: 380,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    drawHorizontalLine: true,
                                    horizontalInterval: 1,
                                    verticalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: AppColors.onSurface
                                            .withOpacity(0.05),
                                        strokeWidth: 0.6,
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: AppColors.onSurface
                                            .withOpacity(0.05),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 20,
                                        minIncluded: true,
                                        interval: result!.dayIntervalOnGraph,
                                        getTitlesWidget: (
                                          double value,
                                          TitleMeta meta,
                                        ) {
                                          return Text(
                                            getNaturalLanguageNameForDay(
                                                value.round()),
                                            textAlign: TextAlign.left,
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: result!.timeIntervalOnGraph,
                                        minIncluded: false,
                                        getTitlesWidget: (
                                          double value,
                                          TitleMeta meta,
                                        ) {
                                          return Text(
                                            "${value.round()} Hr${value == 1 ? "" : "s"}",
                                            textAlign: TextAlign.left,
                                          );
                                        },
                                        reservedSize: 42,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  minX: result!
                                      .actualStartDaySearchStatus.actualDay.day
                                      .toDouble(),
                                  maxX: result!
                                      .actualEndDaySearchStatus.actualDay.day
                                      .toDouble(),
                                  minY: 0,
                                  maxY: result!.maxTime.inHours.toDouble() + 1,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: result!.data.entries.map((e) {
                                        return FlSpot(
                                          e.key.day.toDouble(),
                                          e.value.totalTime.asHours,
                                        );
                                      }).toList(),
                                      isCurved: _chartType != _ChartType.line,
                                      isStepLineChart:
                                          _chartType == _ChartType.step,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.onSurface.withOpacity(0.2),
                                        ],
                                      ),
                                      barWidth: 5,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(
                                        show: false,
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.onSurface
                                                .withOpacity(0.2),
                                          ]
                                              .map((color) =>
                                                  color.withOpacity(0.1))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((e) {
                                          return LineTooltipItem(
                                            result!
                                                .getStatAt(e.x.toInt())
                                                .totalTime
                                                .timeShort,
                                            const TextStyle(
                                              fontSize: 12,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      getTooltipColor: (touchedSpot) {
                                        return AppColors.surface;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(10),
                            const Align(
                              child: Text(
                                "System Uptime Graph",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const Gap(20),
                            if (!result!
                                .actualStartDaySearchStatus.accurate) ...[
                              Text(
                                "Note: You don't have an individual session on selected start day \"${DateFormat("MMM d, yyyy").format(_startTime!)}\"${!_startTime!.isSameDay(result!.actualStartDaySearchStatus.actualDay) ? ", tried to load sessions from back up-to \"${DateFormat("MMM d, yyyy").format(result!.actualStartDaySearchStatus.actualDay)}\" instead." : "."}",
                              ),
                            ],
                            if (!result!.actualEndDaySearchStatus.accurate) ...[
                              Text(
                                "Note: You don't have an individual session on selected end day \"${DateFormat("MMM d, yyyy").format(_endTime!)}\"${!_endTime!.isSameDay(result!.actualEndDaySearchStatus.actualDay) ? ", tried to load sessions from back up-to \"${DateFormat("MMM d, yyyy").format(result!.actualEndDaySearchStatus.actualDay)}\" instead." : "."}",
                              ),
                            ],
                            const Text(
                              "Session Summary",
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            const Gap(10),
                            SizedBox(
                              height: 900,
                              child: ListView.builder(
                                itemCount: result!.data.length,
                                itemBuilder: (context, index) {
                                  final day = result!.data.keys.elementAt(
                                      result!.data.length - index - 1);
                                  final stats = result!.data[day]!;
                                  return ExpansionTile(
                                    initiallyExpanded: index == 0,
                                    title: Text(
                                      DateFormat("MMM d, ''yy (EEE)")
                                          .format(day),
                                      style: TextStyle(
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          stats.totalTime.timeShort,
                                          style: TextStyle(
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const Gap(5),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                      ],
                                    ),
                                    children: [
                                      ...stats.sessions.map(
                                        (session) {
                                          return ListTile(
                                            onTap: () {
                                              // does nothing as of v1.0.0
                                              // the sole purpose of adding this empty callback
                                              // is to let the user see on which session entry he is
                                              // currently viewing without location the cursor.
                                            },
                                            tileColor: session.hasTag
                                                ? AppColors.secondary
                                                    .withOpacity(0.05)
                                                : null,
                                            splashColor: AppColors.primary
                                                .withOpacity(0.1),
                                            focusColor: AppColors.primary
                                                .withOpacity(0.2),
                                            hoverColor: AppColors.primary
                                                .withOpacity(0.05),
                                            mouseCursor:
                                                SystemMouseCursors.basic,
                                            title: Text(
                                              "Session ${session.id}",
                                              style: TextStyle(
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            subtitle: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  session.dayRange,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.onSurface,
                                                    fontWeight: FontWeight.w600
                                                        .themed(brightness),
                                                  ),
                                                ),
                                                Text(
                                                  session.timeRange,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.onSurface,
                                                    fontWeight: FontWeight.w600
                                                        .themed(brightness),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: SizedBox(
                                              width: 140,
                                              height: 50,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${session.hasTag ? "~" : ""}${session.time.timeShort}",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.onSurface,
                                                      fontWeight: FontWeight
                                                          .w600
                                                          .themed(brightness),
                                                    ),
                                                  ),
                                                  if (session.hasTag) ...[
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Get.to(() {
                                                            return SessionTagInfoPage(
                                                              session: session,
                                                            );
                                                          });
                                                        },
                                                        child: Tooltip(
                                                          message:
                                                              "Click to know more",
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                session
                                                                    .tagDisplayName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  color: AppColors
                                                                      .onSurface,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600
                                                                          .themed(
                                                                              brightness),
                                                                ),
                                                              ),
                                                              const Gap(3),
                                                              Icon(
                                                                Icons
                                                                    .info_outlined,
                                                                size: 14,
                                                                color: AppColors
                                                                    .onSurface,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: !_showPicker
                    ? Row(
                        key: const ValueKey("pick-buttons"),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_startTime != null && _endTime != null) ...[
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _hideControls = !_hideControls;
                                });
                              },
                              tooltip: _hideControls
                                  ? "Show Controls"
                                  : "Hide Controls",
                              icon: Icon(
                                _hideControls
                                    ? Icons.keyboard_arrow_left_rounded
                                    : Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                            const Gap(5),
                          ],
                          if (!_hideControls) ...[
                            if (_startTime != null && _endTime != null) ...[
                              const Text("From"),
                              const Gap(5),
                            ],
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _pickerMode = "start-date";
                                  _showPicker = true;
                                });
                              },
                              tooltip:
                                  "Specify the date from which sessions will be shown",
                              icon: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _startTime == null
                                        ? "Pick Start Date"
                                        : DateFormat("MMM d, yyyy")
                                            .format(_startTime!),
                                  ),
                                  if (_startTime != null) ...[
                                    const Text(
                                      "Click to change",
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Gap(5),
                            if (_startTime != null && _endTime != null) ...[
                              const Gap(5),
                              const Text("to"),
                              const Gap(5),
                            ],
                            const Gap(5),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _pickerMode = "end-date";
                                  _showPicker = true;
                                });
                              },
                              tooltip:
                                  "Specify the date till which sessions will be shown",
                              icon: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _endTime == null
                                        ? "Pick End Date"
                                        : DateFormat("MMM d, yyyy")
                                            .format(_endTime!),
                                  ),
                                  if (_endTime != null) ...[
                                    const Text(
                                      "Click to change",
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (_startTime != null && _endTime != null) ...[
                              const Gap(10),
                              Tooltip(
                                message: "Click to load sessions",
                                child: TextButton(
                                  onPressed: () async {
                                    if (_searchInProgress) return;
                                    setState(() {
                                      result = null;
                                      _searchInProgress = true;
                                      _hideControls = true;
                                    });
                                    try {
                                      result = await SessionReader.readTimeline(
                                        _startTime!,
                                        _endTime!,
                                      );
                                    } catch (e, stack) {
                                      debugPrint("$e\n$stack");
                                    } finally {
                                      setState(() {
                                        _searchInProgress = false;
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: !_searchInProgress
                                        ? Colors.transparent
                                        : Colors.grey.withOpacity(0.21),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.done,
                                          color: AppColors.onSurface,
                                        ),
                                        const Gap(4),
                                        Text(
                                          "Apply",
                                          style: TextStyle(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      )
                    : SizedBox(
                        width: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Theme(
                              data: brightness == Brightness.light
                                  ? ThemeData.light()
                                  : ThemeData.dark(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: result != null
                                      ? AppColors.surface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CalendarDatePicker(
                                  initialDate: _pickerMode == "start-date"
                                      ? (_startTime ?? _now)
                                      : (_endTime ?? _now),
                                  currentDate: _now,
                                  firstDate: DateTime(2000, 1, 1),
                                  lastDate: _now,
                                  onDateChanged: (value) {
                                    if (_pickerMode == "start-date") {
                                      _startTime = value;
                                    } else {
                                      _endTime = value;
                                    }
                                  },
                                ),
                              ),
                            ),
                            const Gap(10),
                            IconButton(
                              onPressed: () {
                                // handling natural input selection
                                if (_endTime == null &&
                                    _pickerMode == "end-date") {
                                  _endTime = _now;
                                } else if (_startTime == null &&
                                    _pickerMode == "start-date") {
                                  _startTime = _now;
                                }
                                setState(() {
                                  _showPicker = false;
                                });
                              },
                              icon: const Text("Done"),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (_searchInProgress) ...[
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.onSurface,
                    ),
                    const Gap(20),
                    Text(
                      "Reading nakime's session storage",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600.themed(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Align(
              alignment: Alignment.bottomLeft,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
                child: !_showGoToTopButton ||
                        result == null ||
                        result!.data.isEmpty
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton.filled(
                          onPressed: () {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          },
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
