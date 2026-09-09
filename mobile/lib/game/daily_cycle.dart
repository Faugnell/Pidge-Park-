class DailyCycle {
  const DailyCycle({this.resetHour = 4});

  final int resetHour;

  DateTime startFor(DateTime now) {
    final todayReset = DateTime(now.year, now.month, now.day, resetHour);
    return now.isBefore(todayReset)
        ? todayReset.subtract(const Duration(days: 1))
        : todayReset;
  }

  DateTime nextReset(DateTime now) {
    final start = startFor(now);
    return DateTime(start.year, start.month, start.day + 1, resetHour);
  }

  String keyFor(DateTime now) {
    final start = startFor(now);
    return '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
  }
}
