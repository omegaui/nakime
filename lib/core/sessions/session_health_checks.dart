import 'dart:io';

import 'package:nakime/core/constants/service_constants.dart';

class SessionHealthChecks {
  SessionHealthChecks._();

  static Future<int> errorCount() async {
    if (await FileSystemEntity.isDirectory(ServiceConstants.errorLogsDir)) {
      final dir = Directory(ServiceConstants.errorLogsDir);
      final stream = dir.list();
      final count = await stream.length;
      return count;
    }
    return 0;
  }
}
