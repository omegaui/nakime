import 'package:nakime/core/extensions/number_extension.dart';

extension TimeExtension on Duration {
  String get time {
    var data = toString();
    data = data.substring(0, data.indexOf('.'));
    final split = data.split(":");
    var hours = split[0].asInt();
    final min = split[1].asInt();
    final sec = split[2].asInt();
    var content = "";
    if (hours > 0) {
      if (hours >= 24) {
        final days = hours ~/ 24;
        final s = days > 1 ? "s" : "";
        content += "$days day$s ";
        hours = hours.remainder(24);
      }
      final s = hours > 1 ? "s" : "";
      content += "$hours hour$s ";
    }
    if (hours > 0 || min > 0) {
      final s = hours > 1 ? "s" : "";
      content += "$min minute$s ";
    }
    final s = hours > 1 ? "s" : "";
    content += "$sec second$s";
    return content;
  }
}
