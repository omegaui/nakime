import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nakime/core/constants/service_constants.dart';
import 'package:nakime/core/extensions/number_extension.dart';

enum LiveSessionState { stable, empty, error }

class LiveSession {
  LiveSession._();

  static LiveSessionState _state = LiveSessionState.stable;

  static LiveSessionState get state => _state;

  static DateTime _systemStartupTime = DateTime(0);

  static DateTime get systemStartupTime => _systemStartupTime;

  static Future<void> init() async {
    bool dataDirExists =
        await FileSystemEntity.isDirectory(ServiceConstants.dataDir);
    bool liveSessionFileExists =
        await FileSystemEntity.isFile(ServiceConstants.liveSessionFile);
    if (dataDirExists && liveSessionFileExists) {
      try {
        final liveSessionData =
            await File(ServiceConstants.liveSessionFile).readAsString();
        final lineTerminator = liveSessionData.indexOf('\n');
        if (lineTerminator >= 0) {
          final day = liveSessionData
              .substring(0, lineTerminator)
              .replaceAll("\n", "")
              .replaceAll("\r", "")
              .split('-');
          final time = liveSessionData
              .substring(lineTerminator + 1)
              .replaceAll("\n", "")
              .replaceAll("\r", "")
              .split(":");
          _systemStartupTime = DateTime(
            day[2].asInt(),
            day[1].asInt(),
            day[0].asInt(),
            time[0].asInt(),
            time[1].asInt(),
            time[2].asInt(),
          );
          debugPrint("[Info] LiveSession: Started at $_systemStartupTime");
        }
      } catch (e, stack) {
        _state = LiveSessionState.error;
        debugPrint("[ERROR] LiveSession.init(): $e\n$stack");
      }
    } else {
      _state = LiveSessionState.empty;
    }
  }
}
