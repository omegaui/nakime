import 'dart:io';

import 'package:excel/excel.dart';
import 'package:nakime/core/constants/service_constants.dart';
import 'package:nakime/core/extensions/day_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/session_reader.dart';

class SessionExportUtils {
  SessionExportUtils._();

  static Future<String> exportExcel(List<Session> sessions) async {
    final now = DateTime.now();
    final exportFileName = now.toExportFilepath();
    if (!(await FileSystemEntity.isDirectory(ServiceConstants.exportDir))) {
      await Directory(ServiceConstants.exportDir).create();
    }
    final excel = Excel.createExcel();
    excel.appendRow("Sheet1", [
      TextCellValue("Session no"),
      TextCellValue("Start Day"),
      TextCellValue("End Day"),
      TextCellValue("Start Time"),
      TextCellValue("End Time"),
      TextCellValue("Duration"),
      TextCellValue("Tag"),
    ]);
    for (final session in sessions) {
      excel.appendRow("Sheet1", [
        IntCellValue(sessions.indexOf(session) + 1),
        DateCellValue.fromDateTime(session.start),
        DateCellValue.fromDateTime(session.end),
        TimeCellValue.fromTimeOfDateTime(session.start),
        TimeCellValue.fromTimeOfDateTime(session.end),
        TextCellValue(session.time.timeShort),
        TextCellValue(session.tag.isEmpty ? "normal" : session.tag),
      ]);
    }
    excel.appendRow("Sheet1", [
      TextCellValue("Total"),
      TextCellValue(""),
      TextCellValue(""),
      TextCellValue(""),
      TextCellValue(""),
      TextCellValue(SessionGroupStats(sessions: sessions).totalTime.timeShort),
      TextCellValue(""),
    ]);
    final data = excel.encode()!;
    await File(exportFileName).writeAsBytes(data);
    return exportFileName;
  }
}
