import 'package:flutter/material.dart';

import '../core/utils.dart';
import 'task.dart';

/// Filtros aplicáveis à lista de tarefas.
class TaskFilter {
  const TaskFilter({
    this.priorities = const {},
    this.categoryId,
    this.projectId,
    this.status,
    this.overdueOnly = false,
    this.range,
  });

  final Set<Priority> priorities;
  final int? categoryId;
  final int? projectId;
  final TaskStatus? status;
  final bool overdueOnly;
  final DateTimeRange? range;

  int get activeCount =>
      (priorities.isNotEmpty ? 1 : 0) +
      (categoryId != null ? 1 : 0) +
      (projectId != null ? 1 : 0) +
      ((status != null || overdueOnly) ? 1 : 0) +
      (range != null ? 1 : 0);

  bool get isActive => activeCount > 0;

  bool matches(Task t) {
    if (priorities.isNotEmpty && !priorities.contains(t.priority)) return false;
    if (categoryId != null && t.categoryId != categoryId) return false;
    if (projectId != null && t.projectId != projectId) return false;
    if (status != null && t.status != status) return false;
    if (overdueOnly && !t.isOverdue) return false;
    if (range != null) {
      final start = dateOnly(range!.start);
      final end = dateOnly(range!.end);
      if (t.dueDate.isBefore(start) || t.dueDate.isAfter(end)) return false;
    }
    return true;
  }
}
