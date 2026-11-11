import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/quote_controller.dart';
import '../controllers/task_controller.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/task.dart';
import '../widgets/app_card.dart';
import '../widgets/error_view.dart';
import '../widgets/quote_card.dart';
import '../widgets/responsive_body.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';
import 'organization_screen.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart';

/// Tela inicial: resumo, frase motivacional e tarefas em destaque.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  void _newTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TaskFormScreen()),
    );
  }

  void _openList(
    BuildContext context,
    String title,
    List<Task> Function(TaskController) selector,
    String empty,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskListScreen(
          title: title,
          emptyMessage: empty,
          selector: selector,
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final tasks = context.read<TaskController>();
    final quote = context.read<QuoteController>();
    final error = await tasks.refresh();
    await quote.loadToday();
    if (error != null && context.mounted) {
      showSnack(context, error, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();

    final Widget body = switch (c.state) {
      LoadState.loading => const Center(child: CircularProgressIndicator()),
      LoadState.error => ErrorView(
          message: c.error ?? 'Erro ao carregar.',
          onRetry: c.load,
        ),
      LoadState.ready => _buildContent(context, c),
    };

    return Scaffold(
      body: SafeArea(child: body),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newTask(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaskController c) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final todayPending = c.todayTasks.where((t) => !t.isDone).toList();
    final overdue = c.overdueTasks;
    final progress =
        c.todayCount == 0 ? 0.0 : c.todayDoneCount / c.todayCount;

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ResponsiveBody(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting(), style: text.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        Fmt.longDate(DateTime.now()),
                        style: text.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [kPurple, kBlue]),
                  ),
                  child: const Icon(Icons.task_alt_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: CircularProgressIndicator(
                              value: v,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor:
                                  cs.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          Text('${(v * 100).round()}%',
                              style: text.titleMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progresso de hoje', style: text.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          c.todayCount == 0
                              ? 'Nenhuma tarefa para hoje. Aproveite para planejar!'
                              : '${c.todayDoneCount} de ${c.todayCount} tarefas concluídas',
                          style: text.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final cols = constraints.maxWidth > 560 ? 4 : 2;
                final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
                Widget cell(Widget child) => SizedBox(width: w, child: child);
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    cell(StatCard(
                      icon: Icons.pending_actions_rounded,
                      label: 'Pendentes',
                      value: c.pendingCount,
                      color: kPurple,
                      onTap: () => _openList(context, 'Pendentes',
                          (x) => x.pendingTasks, 'Nenhuma tarefa pendente.'),
                    )),
                    cell(StatCard(
                      icon: Icons.task_alt_rounded,
                      label: 'Concluídas',
                      value: c.doneCount,
                      color: const Color(0xFF10B981),
                      onTap: () => _openList(context, 'Concluídas',
                          (x) => x.completedTasks, 'Nenhuma tarefa concluída ainda.'),
                    )),
                    cell(StatCard(
                      icon: Icons.warning_amber_rounded,
                      label: 'Atrasadas',
                      value: c.overdueCount,
                      color: cs.error,
                      onTap: () => _openList(context, 'Atrasadas',
                          (x) => x.overdueTasks, 'Você está em dia!'),
                    )),
                    cell(StatCard(
                      icon: Icons.today_rounded,
                      label: 'Para hoje',
                      value: c.todayCount,
                      color: kBlue,
                      onTap: () => _openList(context, 'Hoje',
                          (x) => x.todayTasks, 'Nada agendado para hoje.'),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            const QuoteCard(),
            SectionHeader(
              title: 'Para hoje',
              actionLabel: 'Ver tudo',
              onAction: () => onOpenTab(1),
            ),
            if (todayPending.isEmpty)
              AppCard(
                child: Row(
                  children: [
                    Icon(Icons.celebration_outlined, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.todayCount == 0
                            ? 'Sem tarefas para hoje.'
                            : 'Tudo concluído por hoje. Bom trabalho!',
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (var i = 0; i < todayPending.length && i < 4; i++)
                TaskCard(task: todayPending[i], index: i),
            if (overdue.isNotEmpty) ...[
              SectionHeader(
                title: 'Atrasadas',
                actionLabel: 'Ver todas',
                onAction: () => _openList(context, 'Atrasadas',
                    (x) => x.overdueTasks, 'Você está em dia!'),
              ),
              for (var i = 0; i < overdue.length && i < 3; i++)
                TaskCard(task: overdue[i], index: i),
            ],
            const SizedBox(height: 14),
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const OrganizationScreen()),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_special_outlined, color: cs.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categorias e projetos', style: text.titleMedium),
                        Text(
                          '${c.categories.length} categorias · ${c.projects.length} projetos',
                          style: text.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
