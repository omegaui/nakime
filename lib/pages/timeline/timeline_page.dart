import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/extras.dart';
import 'package:nakime/core/sessions/session_reader.dart';

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
  bool _showStepLineChart = true;

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
                                    _showStepLineChart = !_showStepLineChart;
                                  });
                                },
                                tooltip:
                                    "Export your usage data in excel format",
                                icon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _showStepLineChart
                                          ? "Step Chart"
                                          : "Smooth Chart",
                                    ),
                                    const Gap(4),
                                    Icon(
                                      _showStepLineChart
                                          ? Icons.bar_chart
                                          : Icons.show_chart,
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
                  if (result != null) ...[
                    Expanded(
                      child: SingleChildScrollView(
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
                                      isCurved: true,
                                      isStepLineChart: _showStepLineChart,
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
                            const Gap(20),
                            if (!result!
                                .actualStartDaySearchStatus.accurate) ...[
                              Text(
                                "You don't have an individual session on selected start day \"${DateFormat("MMM d, yyyy").format(_startTime!)}\"${!_startTime!.isSameDay(result!.actualStartDaySearchStatus.actualDay) ? ", tried to load sessions from back up-to \"${DateFormat("MMM d, yyyy").format(result!.actualStartDaySearchStatus.actualDay)}\" instead." : "."}",
                              ),
                            ],
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
          ],
        ),
      ),
    );
  }
}
