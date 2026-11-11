import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Remove a parte de horário de uma data.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

/// Formatadores de data e hora em português.
class Fmt {
  Fmt._();

  static String shortDate(DateTime d) =>
      DateFormat("d 'de' MMM", 'pt_BR').format(d);

  static String longDate(DateTime d) =>
      capitalize(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(d));

  static String time(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String dateTime(DateTime d) =>
      DateFormat("d 'de' MMM 'às' HH:mm", 'pt_BR').format(d);

  static String relativeDay(DateTime d) {
    final now = DateTime.now();
    final diff = DateTime.utc(d.year, d.month, d.day)
        .difference(DateTime.utc(now.year, now.month, now.day))
        .inDays;
    switch (diff) {
      case 0:
        return 'Hoje';
      case 1:
        return 'Amanhã';
      case -1:
        return 'Ontem';
      default:
        return shortDate(d);
    }
  }
}

/// Exibe uma mensagem rápida (SnackBar) padronizada.
void showSnack(BuildContext context, String message, {bool error = false}) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: error ? TextStyle(color: cs.onError) : null,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? cs.error : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
