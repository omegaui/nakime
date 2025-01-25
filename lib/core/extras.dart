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
