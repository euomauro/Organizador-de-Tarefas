import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../core/utils.dart';
import '../models/task.dart';
import 'app_card.dart';
import 'fade_in.dart';
import 'task_actions.dart';

/// Cartão de tarefa com swipe (concluir / excluir), favorito e atalho de conclusão.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.index = 0});

  final Task task;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TaskController>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = controller.categoryById(task.categoryId);
    final project = controller.projectById(task.projectId);
    final overdue = task.isOverdue;

    final dateText = task.dueTime == null
        ? Fmt.relativeDay(task.dueDate)
        : '${Fmt.relativeDay(task.dueDate)} · ${Fmt.time(task.dueTime!)}';

    return FadeIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Dismissible(
          key: ValueKey('task-${task.id}'),
          background: _SwipeBackground(
            color: const Color(0xFF10B981),
            icon: task.isDone ? Icons.undo_rounded : Icons.check_rounded,
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _SwipeBackground(
            color: cs.error,
            icon: Icons.delete_outline_rounded,
            alignment: Alignment.centerRight,
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await controller.toggleDone(task);
              return false;
            }
            return true;
          },
          onDismissed: (_) => deleteWithUndo(context, task),
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(10, 12, 4, 12),
            onTap: () => openTask(context, task),
            child: Row(
              children: [
                _CheckCircle(
                  task: task,
                  onTap: () => controller.toggleDone(task),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? cs.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _Meta(
                            icon: overdue
                                ? Icons.warning_amber_rounded
                                : Icons.event_rounded,
                            text: dateText,
                            color: overdue ? cs.error : cs.onSurfaceVariant,
                          ),
                          _Meta(
                            icon: Icons.flag_rounded,
                            text: task.priority.label,
                            color: task.priority.color,
                          ),
                          if (category != null)
                            _Meta(
                              icon: category.icon,
                              text: category.name,
                              color: category.color,
                            ),
                          if (project != null)
                            _Meta(
                              icon: Icons.folder_outlined,
                              text: project.name,
                              color: project.color,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: task.isFavorite
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                  onPressed: () => controller.toggleFavorite(task),
                  icon: Icon(
                    task.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: task.isFavorite
                        ? const Color(0xFFF59E0B)
                        : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = task.priority.color;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.isDone ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: task.isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : task.status == TaskStatus.inProgress
                  ? Icon(Icons.more_horiz_rounded, size: 16, color: color)
                  : null,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
