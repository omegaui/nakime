import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nakime/config/app_colors.dart';

String getNaturalLanguageNameForDay(int day) {
  if (day < 1 || day > 31) {
    throw ArgumentError("Day must be between 1 and 31.");
  }

  String suffix;
  if (day % 10 == 1 && day != 11) {
    suffix = "st";
  } else if (day % 10 == 2 && day != 12) {
    suffix = "nd";
  } else if (day % 10 == 3 && day != 13) {
    suffix = "rd";
  } else {
    suffix = "th";
  }

  return "$day$suffix";
}

Future<bool> isUptimeInstalled() async {
  final result = await Process.run(
    'uptime',
    ['--help'],
  );
  return result.exitCode == 0;
}

void showSnackbar(String title, String message,
    {VoidCallback? onTap, bool stayLonger = true}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: AppColors.surface.withOpacity(0.9),
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: stayLonger ? 10 : 3),
    margin: const EdgeInsets.only(
      bottom: 12,
      left: 12,
      right: 12,
    ),
    onTap: (snack) {
      onTap?.call();
    },
  );
}
