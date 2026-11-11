import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../core/utils.dart';
import '../models/task.dart';
import '../widgets/app_card.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_actions.dart';
import 'task_form_screen.dart';

/// Detalhes de uma tarefa, com ações de status, favorito, edição e exclusão.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  Future<void> _delete(BuildContext context, Task task) async {
    final ok = await confirmDelete(
      context,
      title: 'Excluir tarefa?',
      message: 'A tarefa "${task.title}" será removida. Você poderá desfazer logo após.',
    );
    if (!ok || !context.mounted) return;
    deleteWithUndo(context, task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final task = c.taskById(taskId);
    if (task == null) return const Scaffold(body: SizedBox.shrink());

    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = c.categoryById(task.categoryId);
    final project = c.projectById(task.projectId);
    final overdue = task.isOverdue;

    Widget info(IconData icon, String label, String value, {Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? cs.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: text.titleSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: task.isFavorite ? 'Remover dos favoritos' : 'Favoritar',
            onPressed: () => c.toggleFavorite(task),
            icon: Icon(
              task.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: task.isFavorite ? const Color(0xFFF59E0B) : null,
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => TaskFormScreen(task: task)),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: () => _delete(context, task),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ResponsiveBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              task.title,
              style: text.headlineSmall?.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(task.status.icon, size: 18),
                  label: Text(task.status.label),
                ),
                Chip(
                  avatar: Icon(Icons.flag_rounded,
                      size: 18, color: task.priority.color),
                  label: Text('Prioridade ${task.priority.label.toLowerCase()}'),
                ),
                if (overdue)
                  Chip(
                    avatar: Icon(Icons.warning_amber_rounded,
                        size: 18, color: cs.error),
                    label: Text('Atrasada', style: TextStyle(color: cs.error)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  info(Icons.event_rounded, 'Data', Fmt.longDate(task.dueDate),
                      color: overdue ? cs.error : null),
                  info(
                    Icons.schedule_rounded,
                    'Horário',
                    task.dueTime == null ? 'Sem horário' : Fmt.time(task.dueTime!),
                  ),
                  info(
                    category?.icon ?? Icons.label_outline_rounded,
                    'Categoria',
                    category?.name ?? 'Nenhuma',
                    color: category?.color,
                  ),
                  info(
                    Icons.folder_outlined,
                    'Projeto',
                    project?.name ?? 'Nenhum',
                    color: project?.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descrição', style: text.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    task.description.isEmpty
                        ? 'Sem descrição.'
                        : task.description,
                    style: text.bodyMedium?.copyWith(
                      height: 1.5,
                      color: task.description.isEmpty
                          ? cs.onSurfaceVariant
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alterar status', style: text.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in TaskStatus.values)
                        ChoiceChip(
                          label: Text(s.label),
                          avatar: Icon(s.icon, size: 18),
                          selected: task.status == s,
                          onSelected: (_) async {
                            final error = await c.setStatus(task, s);
                            if (error != null && context.mounted) {
                              showSnack(context, error, error: true);
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Criada em ${Fmt.dateTime(task.createdAt)}'
              '${task.completedAt != null ? '\nConcluída em ${Fmt.dateTime(task.completedAt!)}' : ''}',
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                final error = await c.toggleDone(task);
                if (error != null && context.mounted) {
                  showSnack(context, error, error: true);
                }
              },
              icon: Icon(task.isDone
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded),
              label: Text(task.isDone ? 'Reabrir tarefa' : 'Concluir tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
