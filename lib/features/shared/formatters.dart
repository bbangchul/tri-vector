String formatDouble(double value, [int precision = 2]) {
  final fixed = value.toStringAsFixed(precision);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}
