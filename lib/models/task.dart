import 'package:flutter/material.dart';

import '../core/utils.dart';

/// Prioridade de uma tarefa.
enum Priority {
  low('Baixa', Color(0xFF10B981), Icons.keyboard_arrow_down_rounded),
  medium('Média', Color(0xFFF59E0B), Icons.drag_handle_rounded),
  high('Alta', Color(0xFFEF4444), Icons.keyboard_arrow_up_rounded);

  const Priority(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Status de uma tarefa.
enum TaskStatus {
  pending('Pendente', Icons.radio_button_unchecked_rounded),
  inProgress('Em andamento', Icons.timelapse_rounded),
  done('Concluída', Icons.check_circle_rounded);

  const TaskStatus(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Tarefa do usuário.
class Task {
  const Task({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.dueTime,
    this.priority = Priority.medium,
    this.categoryId,
    this.projectId,
    this.status = TaskStatus.pending,
    this.isFavorite = false,
    required this.createdAt,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String description;

  /// Apenas a data (sem horário).
  final DateTime dueDate;
  final TimeOfDay? dueTime;
  final Priority priority;
  final int? categoryId;
  final int? projectId;
  final TaskStatus status;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isDone => status == TaskStatus.done;

  /// Data e hora de vencimento. Sem horário, vale até o fim do dia.
  DateTime get dueDateTime => DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime?.hour ?? 23,
        dueTime?.minute ?? 59,
      );

  bool get isOverdue => !isDone && dueDateTime.isBefore(DateTime.now());

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool clearTime = false,
    Priority? priority,
    int? categoryId,
    bool clearCategory = false,
    int? projectId,
    bool clearProject = false,
    TaskStatus? status,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: clearTime ? null : (dueTime ?? this.dueTime),
      priority: priority ?? this.priority,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      projectId: clearProject ? null : (projectId ?? this.projectId),
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'description': description,
        'due_date': _fmtDate(dueDate),
        'due_minutes': dueTime == null ? null : dueTime!.hour * 60 + dueTime!.minute,
        'priority': priority.index,
        'category_id': categoryId,
        'project_id': projectId,
        'status': status.index,
        'is_favorite': isFavorite ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
        'completed_at': completedAt?.millisecondsSinceEpoch,
      };

  factory Task.fromMap(Map<String, dynamic> m) {
    final minutes = m['due_minutes'] as int?;
    final completed = m['completed_at'] as int?;
    return Task(
      id: m['id'] as int?,
      title: m['title'] as String,
      description: (m['description'] as String?) ?? '',
      dueDate: dateOnly(DateTime.parse(m['due_date'] as String)),
      dueTime: minutes == null
          ? null
          : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      priority: Priority.values[m['priority'] as int],
      categoryId: m['category_id'] as int?,
      projectId: m['project_id'] as int?,
      status: TaskStatus.values[m['status'] as int],
      isFavorite: (m['is_favorite'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      completedAt: completed == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completed),
    );
  }
}
