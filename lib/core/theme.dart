import 'package:flutter/material.dart';

import 'constants.dart';

/// Tema Material Design 3 do Organiza (claro e escuro).
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: kPurple,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFFB8A6FF) : kPurple,
      onPrimary: isDark ? const Color(0xFF1E1147) : Colors.white,
      secondary: isDark ? const Color(0xFF7FB2FF) : kBlue,
      onSecondary: isDark ? const Color(0xFF0A2447) : Colors.white,
      surface: isDark ? const Color(0xFF1C1A25) : Colors.white,
      outlineVariant:
          isDark ? const Color(0xFF3A3748) : const Color(0xFFE6E3F5),
    );

    final scaffoldBg =
        isDark ? const Color(0xFF110F17) : const Color(0xFFF5F4FC);

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final t = base.textTheme;
    final textTheme = t
        .copyWith(
          headlineLarge: t.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
          headlineMedium: t.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          headlineSmall: t.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
          titleLarge: t.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}

/// Decoração padrão dos campos de formulário.
InputDecoration appInput(
  BuildContext context, {
  required String label,
  String? hint,
  IconData? icon,
}) {
  final cs = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: cs.surface,
    border: border(cs.outlineVariant),
    enabledBorder: border(cs.outlineVariant),
    focusedBorder: border(cs.primary, 1.6),
    errorBorder: border(cs.error),
    focusedErrorBorder: border(cs.error, 1.6),
  );
}
