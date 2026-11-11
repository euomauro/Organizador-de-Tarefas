import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;

import '../controllers/task_controller.dart';
import '../core/utils.dart';
import '../models/task.dart';
import '../widgets/app_card.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// Calendário mensal com marcadores e lista das tarefas do dia selecionado.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = dateOnly(DateTime.now());
  CalendarFormat _format = CalendarFormat.month;

  void _today() {
    final now = DateTime.now();
    setState(() {
      _focused = now;
      _selected = dateOnly(now);
    });
  }

  void _newTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskFormScreen(initialDate: _selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dayTasks = c.tasksOn(_selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          TextButton.icon(
            onPressed: _today,
            icon: const Icon(Icons.today_rounded, size: 18),
            label: const Text('Hoje'),
          ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 760,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: TableCalendar<Task>(
                    locale: 'pt_BR',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focused,
                    calendarFormat: _format,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mês',
                      CalendarFormat.twoWeeks: '2 semanas',
                      CalendarFormat.week: 'Semana',
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    selectedDayPredicate: (d) => isSameDay(_selected, d),
                    eventLoader: (day) => c.tasksOn(day),
                    onDaySelected: (selected, focused) => setState(() {
                      _selected = DateTime(
                          selected.year, selected.month, selected.day);
                      _focused = focused;
                    }),
                    onFormatChanged: (f) => setState(() => _format = f),
                    onPageChanged: (f) => _focused = f,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      titleTextStyle:
                          text.titleMedium ?? const TextStyle(fontSize: 16),
                      formatButtonTextStyle: TextStyle(
                        color: cs.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: cs.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left_rounded, color: cs.onSurface),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded,
                          color: cs.onSurface),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12),
                      weekendStyle: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: cs.secondary),
                      todayDecoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders<Task>(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        return Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final t in events.take(3))
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.isDone
                                        ? cs.outline
                                        : t.priority.color,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(Fmt.longDate(_selected),
                          style: text.titleMedium),
                    ),
                    Text(
                      '${dayTasks.length} ${dayTasks.length == 1 ? 'tarefa' : 'tarefas'}',
                      style: text.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            if (dayTasks.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded, color: cs.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Nenhuma tarefa neste dia.'),
                        ),
                        TextButton(
                          onPressed: _newTask,
                          child: const Text('Adicionar'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverList.builder(
                  itemCount: dayTasks.length,
                  itemBuilder: (_, i) => TaskCard(task: dayTasks[i], index: i),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova tarefa'),
      ),
    );
  }
}
