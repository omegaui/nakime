import 'package:intl/intl.dart';
import 'package:nakime/core/constants/session_tag_constants.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/number_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';

enum TimeDirection {
  past,
  future,
}

class ActualTimeSearchStatus {
  final DateTime actualDay;
  final bool accurate;

  ActualTimeSearchStatus({required this.actualDay, required this.accurate});
}

class TimelineReadResult {
  final List<DateTime> timeline;
  final Map<DateTime, SessionGroupStats> data;
  final ActualTimeSearchStatus actualStartDaySearchStatus;
  final ActualTimeSearchStatus actualEndDaySearchStatus;
  late double dayIntervalOnGraph;
  late double timeIntervalOnGraph;
  late Duration maxTime;

  SessionGroupStats getStatAt(int day) {
    return data[data.keys.firstWhere((e) => e.day == day)]!;
  }

  bool get isSameMonth =>
      actualStartDaySearchStatus.actualDay.month ==
      actualEndDaySearchStatus.actualDay.month;

  TimelineReadResult({
    required this.timeline,
    required this.data,
    required this.actualStartDaySearchStatus,
    required this.actualEndDaySearchStatus,
  }) {
    if (data.isNotEmpty) {
      maxTime = data.values.first.totalTime;
      for (final stats in data.values) {
        if (stats.totalTime > maxTime) {
          maxTime = stats.totalTime;
        }
      }
      dayIntervalOnGraph = (timeline.length / 7).ceilToDouble().roundToDouble();
      timeIntervalOnGraph =
          (maxTime.asHours / timeline.length).ceilToDouble().roundToDouble();
    } else {
      dayIntervalOnGraph = timeIntervalOnGraph = 1;
      maxTime = Duration.zero;
    }
  }
}

class SessionGroupStats {
  final List<Session> sessions;
  late final Duration totalTime;

  SessionGroupStats({required this.sessions}) {
    totalTime = sessions.fold<Duration>(Duration.zero, (a, b) => a + b.time);
  }
}

class Session {
  final int id;
  final DateTime start;
  final DateTime end;
  final String tag;

  Session({
    required this.id,
    required this.start,
    required this.end,
    required this.tag,
  });

  bool get hasTag => tag.isNotEmpty;

  String get tagDisplayName => SessionTagConstants.getTagDisplayName(tag);

  Duration get time => end.difference(start);

  String get dayRange {
    if (start.isSameDay(end)) {
      return DateFormat("EEE, MMM d, yyyy").format(start);
    } else if (start.isSameYear(end)) {
      return "From ${DateFormat("EEE, MMM d").format(start)} to ${DateFormat("EEE, MMM d").format(end)}";
    }
    return "From ${DateFormat("EEE, MMM d, yyyy").format(start)} to ${DateFormat("EEE, MMM d, yyyy").format(end)}";
  }

  String get timeRange {
    return "${DateFormat("hh:mm a").format(start)} - ${DateFormat("hh:mm a").format(end)}";
  }

  factory Session.fromDoc(Map<String, dynamic> doc) {
    List<String> startDay = doc["SessionStartDay"].split('-');
    List<String> startTime = doc["SessionStartTime"].split(':');
    List<String> endDay = doc["SessionEndDay"].split('-');
    List<String> endTime = doc["SessionEndTime"].split(':');
    final start = DateTime(
      startDay[2].asInt(),
      startDay[1].asInt(),
      startDay[0].asInt(),
      startTime[0].asInt(),
      startTime[1].asInt(),
      startTime[2].asInt(),
    );
    final end = DateTime(
      endDay[2].asInt(),
      endDay[1].asInt(),
      endDay[0].asInt(),
      endTime[0].asInt(),
      endTime[1].asInt(),
      endTime[2].asInt(),
    );
    return Session(
      id: doc["Id"],
      start: start,
      end: end,
      tag: doc['Tag'] ?? "",
    );
  }
}

class SessionReader {
  SessionReader._();

  static const allowedDayTravelIterations = 30;

  static Future<List<Session>> readSession(DateTime day) async {
    List<Session> sessions = [];
    if (await day.doesSessionFileExists()) {
      sessions.addAll(await day.readSessions());
    }
    return sessions;
  }

  /// Reads and returns all sessions between the requested timeline.
  ///
  /// Scenarios to consider to make this functions work perfectly.
  /// 1. System turned on and off on the same day - every day's session file exists.
  /// 2. System turned on and off on different day - only the start day's and end day's file exists.
  ///
  /// In the first scenario, there are no conditions to handle [all clear].
  /// In the second scenario, there are uncertain conditions to handle:
  /// - User requested a timeline whose start day's file isn't present on system
  ///   as it is included in the past timeline.
  ///   In this case, we'll only go 30 days back in time.
  /// - User requested a timeline whose end day's file isn't present on system
  ///   as it is included in the some future timeline.
  ///   In this case, we'll only go 30 days forward from the provided end time.
  /// - User requested a timeline whose start and end point are subset of an existing timeline.
  ///   In this case, we'll try to find the actual start point and end point files
  ///   and read all sessions from them.
  static Future<TimelineReadResult> readTimeline(
    DateTime requestedStart,
    DateTime requestedEnd,
  ) async {
    var startPointExists = await requestedStart.doesSessionFileExists();
    var endPointExists = await requestedEnd.doesSessionFileExists();
    final actualStartDaySearchStatus = await _findActualSessionFile(
      requestedStart,
      TimeDirection.past,
      startPointExists,
    );
    final actualEndDaySearchStatus = await _findActualSessionFile(
      requestedEnd,
      TimeDirection.future,
      endPointExists,
    );
    // collect all existing session files in [timeline] list
    final data = <DateTime, SessionGroupStats>{};
    final timeline = <DateTime>[];
    requestedStart = actualStartDaySearchStatus.actualDay;
    requestedEnd = actualEndDaySearchStatus.actualDay;
    for (var date = requestedStart;
        date.isBefore(requestedEnd) || date.isSameDay(requestedEnd);
        date = date.add(const Duration(days: 1))) {
      if (await date.doesSessionFileExists()) {
        timeline.add(date);
      }
    }
    for (final day in timeline) {
      data[day] = SessionGroupStats(sessions: await day.readSessions());
    }
    return TimelineReadResult(
      timeline: timeline,
      data: data,
      actualStartDaySearchStatus: actualStartDaySearchStatus,
      actualEndDaySearchStatus: actualEndDaySearchStatus,
    );
  }

  static Future<ActualTimeSearchStatus> _findActualSessionFile(
    DateTime requestedDay,
    TimeDirection direction,
    bool fileExists,
  ) async {
    DateTime actualDay = requestedDay;
    for (var i = 0; i < allowedDayTravelIterations && !fileExists; i++) {
      if (direction == TimeDirection.past) {
        actualDay = actualDay.subtract(const Duration(days: 1));
      } else {
        actualDay = actualDay.add(const Duration(days: 1));
      }
      fileExists = await actualDay.doesSessionFileExists();
    }
    return ActualTimeSearchStatus(
      actualDay: actualDay,
      accurate: fileExists,
    );
  }
}
