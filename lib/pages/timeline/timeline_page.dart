import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nakime/config/app_colors.dart';
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
  List<Session> _sessions = [];
  String _pickerMode = "start-date";
  bool _showPicker = false;
  bool _hideControls = false;

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
                        if (_sessions.isNotEmpty) ...[
                          IconButton(
                            onPressed: () {},
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
                      ],
                    ),
                  ),
                  const Gap(20),
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
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.grey.withOpacity(0.21),
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
                                            fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}
