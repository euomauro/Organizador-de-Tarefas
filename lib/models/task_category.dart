import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Categoria personalizada de tarefas.
class TaskCategory {
  const TaskCategory({
    this.id,
    required this.name,
    required this.colorValue,
    required this.iconIndex,
  });

  final int? id;
  final String name;
  final int colorValue;
  final int iconIndex;

  Color get color => Color(colorValue);
  IconData get icon => kCategoryIcons[iconIndex % kCategoryIcons.length];

  factory TaskCategory.fromMap(Map<String, dynamic> m) => TaskCategory(
        id: m['id'] as int?,
        name: m['name'] as String,
        colorValue: m['color'] as int,
        iconIndex: m['icon'] as int,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color': colorValue,
        'icon': iconIndex,
      };
}
