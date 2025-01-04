extension DayExtension on DateTime {
  String toSessionFilename() {
    return "$day-$month-$year.json";
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
