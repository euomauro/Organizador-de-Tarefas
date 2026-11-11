import 'package:flutter/material.dart';

/// Constantes globais do aplicativo.
class AppConstants {
  AppConstants._();

  static const String appName = 'Organiza';
  static const String version = '1.0.0';
  static const String dbName = 'organiza.db';
  static const int dbVersion = 1;
  static const String onboardingKey = 'onboarding_done';
  static const String themeKey = 'theme_mode';
}

/// Cores da identidade visual (roxo e azul).
const Color kPurple = Color(0xFF6C4CF1);
const Color kBlue = Color(0xFF3B82F6);

/// Ícones disponíveis para categorias (o banco guarda apenas o índice).
const List<IconData> kCategoryIcons = [
  Icons.person_outline_rounded,
  Icons.work_outline_rounded,
  Icons.school_outlined,
  Icons.favorite_border_rounded,
  Icons.account_balance_wallet_outlined,
  Icons.shopping_bag_outlined,
  Icons.home_outlined,
  Icons.fitness_center_rounded,
  Icons.flight_takeoff_rounded,
  Icons.lightbulb_outline_rounded,
  Icons.restaurant_outlined,
  Icons.groups_outlined,
];

/// Paleta para categorias e projetos.
const List<Color> kPalette = [
  Color(0xFF6C4CF1),
  Color(0xFF3B82F6),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
];
