const List<String> kMonthsShort = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

const List<String> kMonthsLong = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String two(int n) => n.toString().padLeft(2, '0');

String formatClock(DateTime time) => '${two(time.hour)}:${two(time.minute)}';

String initialsFromName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

String formatRemaining(Duration duration) {
  final totalMinutes = (duration.inSeconds + 59) ~/ 60;
  if (totalMinutes <= 0) return 'menos de 1 min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0) return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  return '$minutes min';
}

String windowLabel(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours > 0) return rest == 0 ? '$hours h' : '$hours h $rest min';
  return '$rest min';
}

String rangeLabel(DateTime start, DateTime end) {
  final startMonth = kMonthsShort[start.month - 1];
  final endMonth = kMonthsShort[end.month - 1];
  if (start.month == end.month) return '${start.day}–${end.day} $endMonth';
  return '${start.day} $startMonth – ${end.day} $endMonth';
}