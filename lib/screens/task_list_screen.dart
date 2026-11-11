import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_card.dart';

/// Lista simples e reativa de tarefas selecionadas por [selector].
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    super.key,
    required this.title,
    required this.selector,
    this.emptyMessage = 'Nenhuma tarefa por aqui.',
  });

  final String title;
  final List<Task> Function(TaskController) selector;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ResponsiveBody(
        child: Consumer<TaskController>(
          builder: (context, c, _) {
            final items = selector(c);
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.inbox_outlined,
                title: 'Lista vazia',
                message: emptyMessage,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: items.length,
              itemBuilder: (_, i) => TaskCard(task: items[i], index: i),
            );
          },
        ),
      ),
    );
  }
}
