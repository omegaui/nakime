
import 'dart:ui';

extension FontWeightExtension on FontWeight {
  FontWeight themed(Brightness brightness) {
    final isDarkMode = brightness == Brightness.dark;
    return isDarkMode ? FontWeight.normal : this;
  }
}
