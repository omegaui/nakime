import 'dart:convert';
import 'dart:io';

import 'package:nakime/core/constants/service_constants.dart';
import 'package:nakime/core/sessions/session_reader.dart';

extension DayExtension on DateTime {
  DateTime get previous {
    return subtract(const Duration(days: 1));
  }

  String toSessionFilename() {
    return "$day-$month-$year.json";
  }

  String toExportFilename() {
    return "$day-$month-$year-$millisecondsSinceEpoch.xlsx";
  }

  String toSessionFilepath() {
    return "${ServiceConstants.dataDir}\\${toSessionFilename()}";
  }

  String toExportFilepath() {
    return "${ServiceConstants.exportDir}\\${toExportFilename()}";
  }

  Future<bool> doesSessionFileExists() async {
    return await FileSystemEntity.isFile(toSessionFilepath());
  }

  Future<List<Session>> readSessions() async {
    final sessions = <Session>[];
    final content = await File(toSessionFilepath()).readAsString();
    final list = jsonDecode(content) as Iterable<dynamic>;
    if (list.isNotEmpty) {
      sessions.addAll(list.map((doc) => Session.fromDoc(doc)));
    }
    return sessions;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  bool isSameMonthOfYear(DateTime other) {
    return year == other.year && month == other.month;
  }
}
