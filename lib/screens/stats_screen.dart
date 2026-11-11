import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/responsive_body.dart';

/// Estatísticas de produtividade com gráficos.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();

    Widget body;
    if (c.state == LoadState.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (c.state == LoadState.error) {
      body = ErrorView(message: c.error ?? 'Erro ao carregar.', onRetry: c.load);
    } else if (c.tasks.isEmpty) {
      body = const EmptyState(
        icon: Icons.insights_rounded,
        title: 'Sem dados ainda',
        message: 'Crie e conclua tarefas para acompanhar sua produtividade.',
      );
    } else {
      body = _buildContent(context, c);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: ResponsiveBody(child: body),
    );
  }

  Widget _buildContent(BuildContext context, TaskController c) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final perDay = c.completedPerDay(_days);
    final totalPeriod = perDay.fold<int>(0, (s, e) => s + e.value);
    final peak = perDay.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final maxY = (peak < 4 ? 4 : peak + 1).toDouble();
    final interval = maxY <= 5 ? 1.0 : (maxY / 4).ceilToDouble();
    final labelStep = _days <= 7 ? 1 : (_days <= 14 ? 2 : 5);
    final barWidth = _days <= 7 ? 16.0 : (_days <= 14 ? 10.0 : 5.0);
    final fmtDay = DateFormat(_days <= 7 ? 'E' : 'd/M', 'pt_BR');

    final byPriority = c.pendingByPriority;
    final pendingTotal = c.pendingCount;
    final stats = c.categoryStats;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: c.completionRate),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 84,
                              height: 84,
                              child: CircularProgressIndicator(
                                value: v,
                                strokeWidth: 9,
                                strokeCap: StrokeCap.round,
                                backgroundColor:
                                    cs.primary.withValues(alpha: 0.12),
                              ),
                            ),
                            Text('${(v * 100).round()}%',
                                style: text.titleLarge),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Taxa de conclusão', style: text.titleSmall),
                    Text(
                      '${c.doneCount} de ${c.totalCount}',
                      style: text.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 44, color: Color(0xFFF59E0B)),
                    const SizedBox(height: 8),
                    Text('${c.streak}',
                        style: text.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(c.streak == 1 ? 'dia seguido' : 'dias seguidos',
                        style: text.titleSmall),
                    Text(
                      'com tarefas concluídas',
                      textAlign: TextAlign.center,
                      style: text.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Mini(label: 'Total', value: c.totalCount, color: cs.primary),
              _Mini(
                  label: 'Concluídas',
                  value: c.doneCount,
                  color: const Color(0xFF10B981)),
              _Mini(label: 'Pendentes', value: c.pendingCount, color: cs.secondary),
              _Mini(label: 'Atrasadas', value: c.overdueCount, color: cs.error),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conclusões por dia', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                '$totalPeriod ${totalPeriod == 1 ? 'tarefa concluída' : 'tarefas concluídas'} nos últimos $_days dias',
                style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 dias')),
                  ButtonSegment(value: 14, label: Text('14 dias')),
                  ButtonSegment(value: 30, label: Text('30 dias')),
                ],
                selected: {_days},
                onSelectionChanged: (s) => setState(() => _days = s.first),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: cs.outlineVariant,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: interval,
                          getTitlesWidget: (v, meta) => Text(
                            v.toInt().toString(),
                            style: text.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            if (i < 0 || i >= perDay.length) {
                              return const SizedBox.shrink();
                            }
                            if (i % labelStep != 0 && i != perDay.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                fmtDay.format(perDay[i].key),
                                style: text.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < perDay.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: perDay[i].value.toDouble(),
                              width: barWidth,
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(6),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: cs.primary.withValues(alpha: 0.06),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
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
              Text('Tarefas por categoria', style: text.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 44,
                    sections: [
                      for (final s in stats)
                        PieChartSectionData(
                          value: s.count.toDouble(),
                          color: s.category?.color ?? cs.outline,
                          radius: 46,
                          title: '${s.count}',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (final s in stats)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.category?.color ?? cs.outline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${s.category?.name ?? 'Sem categoria'} (${s.count})',
                            style: text.bodySmall),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pendentes por prioridade', style: text.titleMedium),
              const SizedBox(height: 14),
              if (pendingTotal == 0)
                Text('Nenhuma tarefa pendente. Parabéns!',
                    style: text.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant))
              else
                for (final p in Priority.values.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag_rounded, size: 16, color: p.color),
                            const SizedBox(width: 6),
                            Expanded(child: Text(p.label)),
                            Text('${byPriority[p]}',
                                style: text.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: (byPriority[p] ?? 0) / pendingTotal,
                            color: p.color,
                            backgroundColor: p.color.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('$value',
            style: text.titleLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
