/// Local calendar-day helpers used for daily progress and statistics.
abstract final class DayKey {
  /// `yyyy-MM-dd` in the device's local time zone.
  static String of(DateTime time) {
    final local = time.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }

  static DateTime parse(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  static String previous(String key) {
    final date = parse(key);
    return of(DateTime(date.year, date.month, date.day - 1));
  }

  /// Day number since epoch — stable index for "verse of the day" style picks.
  static int ordinal(DateTime time) {
    final local = time.toLocal();
    return DateTime.utc(local.year, local.month, local.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }
}
