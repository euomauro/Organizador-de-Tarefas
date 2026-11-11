import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/task_filter.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

/// Tarefas organizadas em abas, com pesquisa e filtros.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  TaskFilter _filter = const TaskFilter();

  static const _tabs = ['Hoje', 'Próximas', 'Todas', 'Concluídas', 'Favoritas'];
  static const _emptyIcons = [
    Icons.today_rounded,
    Icons.event_available_rounded,
    Icons.checklist_rounded,
    Icons.task_alt_rounded,
    Icons.star_outline_rounded,
  ];
  static const _emptyTitles = [
    'Nada para hoje',
    'Sem próximas tarefas',
    'Nenhuma tarefa ainda',
    'Nada concluído ainda',
    'Sem favoritas',
  ];
  static const _emptyMessages = [
    'Você não tem tarefas agendadas para hoje.',
    'Nenhuma tarefa futura pendente. Que tal planejar algo?',
    'Crie sua primeira tarefa para começar a se organizar.',
    'As tarefas que você concluir aparecerão aqui.',
    'Toque na estrela de uma tarefa para marcá-la como favorita.',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  void _clearAll() {
    setState(() {
      _query = '';
      _searchController.clear();
      _filter = const TaskFilter();
    });
  }

  Future<void> _openFilters() async {
    final result = await showFilterSheet(context, _filter);
    if (result != null && mounted) setState(() => _filter = result);
  }

  void _newTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TaskFormScreen()),
    );
  }

  List<Task> _base(TaskController c, int index) => switch (index) {
        0 => c.todayTasks,
        1 => c.upcomingTasks,
        2 => c.allTasksSorted,
        3 => c.completedTasks,
        _ => c.favoriteTasks,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: _searching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por título, descrição ou categoria',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                )
              : const Text('Tarefas'),
          actions: [
            IconButton(
              tooltip: _searching ? 'Fechar busca' : 'Buscar',
              onPressed: _toggleSearch,
              icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            ),
            IconButton(
              tooltip: 'Filtros',
              onPressed: _openFilters,
              icon: Badge(
                label: Text('${_filter.activeCount}'),
                isLabelVisible: _filter.isActive,
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            tabs: [for (final t in _tabs) Tab(text: t)],
          ),
        ),
        body: ResponsiveBody(
          child: switch (c.state) {
            LoadState.loading =>
              const Center(child: CircularProgressIndicator()),
            LoadState.error => ErrorView(
                message: c.error ?? 'Erro ao carregar.',
                onRetry: c.load,
              ),
            LoadState.ready => TabBarView(
                children: [
                  for (var i = 0; i < _tabs.length; i++) _buildTab(c, i),
                ],
              ),
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _newTask,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nova tarefa'),
        ),
      ),
    );
  }

  Widget _buildTab(TaskController c, int index) {
    final items = c.applyFilters(_base(c, index), query: _query, filter: _filter);
    final filtering = _query.trim().isNotEmpty || _filter.isActive;

    if (items.isEmpty) {
      if (filtering) {
        return EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Nenhum resultado',
          message: 'Nenhuma tarefa corresponde à busca ou aos filtros atuais.',
          actionLabel: 'Limpar busca e filtros',
          onAction: _clearAll,
        );
      }
      return EmptyState(
        icon: _emptyIcons[index],
        title: _emptyTitles[index],
        message: _emptyMessages[index],
        actionLabel: index <= 2 ? 'Criar tarefa' : null,
        onAction: index <= 2 ? _newTask : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${items.length} ${items.length == 1 ? 'tarefa' : 'tarefas'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }
        return TaskCard(task: items[i - 1], index: i - 1);
      },
    );
  }
}
