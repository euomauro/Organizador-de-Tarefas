import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../screens/task_detail_screen.dart';

/// Abre a tela de detalhes da tarefa.
void openTask(BuildContext context, Task task) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id!)),
  );
}

/// Exclui a tarefa e oferece a opção de desfazer.
void deleteWithUndo(BuildContext context, Task task) {
  final messenger = ScaffoldMessenger.of(context);
  final controller = context.read<TaskController>();
  controller.deleteTask(task);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Tarefa excluída'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => controller.restoreTask(task),
        ),
      ),
    );
}

/// Diálogo de confirmação para ações destrutivas.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
