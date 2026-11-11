import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organiza/models/task.dart';

void main() {
  group('Task', () {
    test('toMap/fromMap preservam os dados', () {
      final task = Task(
        id: 7,
        title: 'Estudar Flutter',
        description: 'Capítulo de estado',
        dueDate: DateTime(2026, 11, 12),
        dueTime: const TimeOfDay(hour: 9, minute: 30),
        priority: Priority.high,
        categoryId: 2,
        projectId: 3,
        status: TaskStatus.inProgress,
        isFavorite: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );

      final copy = Task.fromMap(task.toMap());

      expect(copy.id, 7);
      expect(copy.title, 'Estudar Flutter');
      expect(copy.dueDate, DateTime(2026, 11, 12));
      expect(copy.dueTime, const TimeOfDay(hour: 9, minute: 30));
      expect(copy.priority, Priority.high);
      expect(copy.status, TaskStatus.inProgress);
      expect(copy.isFavorite, isTrue);
      expect(copy.completedAt, isNull);
    });

    test('tarefa vencida e não concluída é atrasada', () {
      final past = DateTime.now().subtract(const Duration(days: 2));
      final task = Task(
        title: 'Antiga',
        dueDate: DateTime(past.year, past.month, past.day),
        createdAt: DateTime.now(),
      );
      expect(task.isOverdue, isTrue);
      expect(task.copyWith(status: TaskStatus.done).isOverdue, isFalse);
    });

    test('copyWith limpa categoria e horário', () {
      final task = Task(
        title: 'X',
        dueDate: DateTime(2026, 1, 1),
        dueTime: const TimeOfDay(hour: 8, minute: 0),
        categoryId: 1,
        createdAt: DateTime.now(),
      );
      final cleared = task.copyWith(clearCategory: true, clearTime: true);
      expect(cleared.categoryId, isNull);
      expect(cleared.dueTime, isNull);
    });
  });
}
