import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nakime/core/constants/service_constants.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/number_extension.dart';

class Session {
  final int id;
  final DateTime start;
  final DateTime end;

  Session({
    required this.id,
    required this.start,
    required this.end,
  });

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
    return "From ${DateFormat("HH:mm:ss").format(start)} to ${DateFormat("HH:mm:ss").format(end)}";
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
      startDay[0].asInt(),
      endTime[0].asInt(),
      endTime[1].asInt(),
      endTime[2].asInt(),
    );
    return Session(
      id: doc["Id"],
      start: start,
      end: end,
    );
  }
}

class SessionReader {
  SessionReader._();

  static Future<List<Session>> readSession(DateTime day) async {
    List<Session> sessions = [];
    final sessionFilename = day.toSessionFilename();
    final sessionFilePath = "${ServiceConstants.dataDir}\\$sessionFilename";
    final sessionExist = await FileSystemEntity.isFile(sessionFilePath);
    if (sessionExist) {
      final content = await File(sessionFilePath).readAsString();
      final list = jsonDecode(content) as Iterable<dynamic>;
      if (list.isNotEmpty) {
        sessions.addAll(list.map((doc) => Session.fromDoc(doc)));
      }
    }
    return sessions;
  }
}
