const List<String> dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

String formatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  return '$day/$month/${d.year}';
}

String formatPrice(double price) {
  final isInt = price == price.roundToDouble();
  return '\$${price.toStringAsFixed(isInt ? 0 : 2)}';
}

String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final suffix = h >= 12 ? 'p. m.' : 'a. m.';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $suffix';
}

String formatSchedule(Set<int> days, int open, int close) {
  if (days.isEmpty) return 'Sin días definidos';
  final sorted = days.toList()..sort();
  final dayText = sorted.length == 7
      ? 'Todos los días'
      : sorted.map((d) => dayNames[d - 1]).join(', ');
  return '$dayText · ${formatMinutes(open)} a ${formatMinutes(close)}';
}
