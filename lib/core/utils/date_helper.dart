import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  /// Compares year/month/day of the device's local time.
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final d = date.toLocal();
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static String format(DateTime? date) => date == null
      ? '—'
      : DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());

  /// ISO-8601 with the local UTC offset, e.g. 2026-10-29T10:30:00+05:30.
  static String toIsoWithOffset(DateTime date) {
    final d = date.toLocal();
    final o = d.timeZoneOffset;
    final sign = o.isNegative ? '-' : '+';
    final h = o.inHours.abs().toString().padLeft(2, '0');
    final m = (o.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final base = d.toIso8601String().split('.').first;
    return '$base$sign$h:$m';
  }
}
