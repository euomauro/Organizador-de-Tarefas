import 'package:flutter/material.dart';

/// Projeto que agrupa tarefas.
class Project {
  const Project({this.id, required this.name, required this.colorValue});

  final int? id;
  final String name;
  final int colorValue;

  Color get color => Color(colorValue);

  factory Project.fromMap(Map<String, dynamic> m) => Project(
        id: m['id'] as int?,
        name: m['name'] as String,
        colorValue: m['color'] as int,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color': colorValue,
      };
}
