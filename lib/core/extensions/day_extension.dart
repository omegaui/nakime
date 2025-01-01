
extension DayExtension on DateTime {
  String toSessionFilename() {
    return "$day-$month-$year.json";
  }
}

