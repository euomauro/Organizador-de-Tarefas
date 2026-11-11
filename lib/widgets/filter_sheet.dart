import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../core/utils.dart';
import '../models/task.dart';
import '../models/task_filter.dart';

/// Abre a folha de filtros. Retorna o novo filtro, ou null se cancelado.
Future<TaskFilter?> showFilterSheet(BuildContext context, TaskFilter current) {
  return showModalBottomSheet<TaskFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final TaskFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<Priority> _priorities;
  int? _categoryId;
  int? _projectId;
  TaskStatus? _status;
  bool _overdue = false;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _priorities = {...f.priorities};
    _categoryId = f.categoryId;
    _projectId = f.projectId;
    _status = f.status;
    _overdue = f.overdueOnly;
    _range = f.range;
  }

  void _reset() => setState(() {
        _priorities = {};
        _categoryId = null;
        _projectId = null;
        _status = null;
        _overdue = false;
        _range = null;
      });

  DateTimeRange get _today {
    final t = dateOnly(DateTime.now());
    return DateTimeRange(start: t, end: t);
  }

  DateTimeRange get _next7 {
    final t = dateOnly(DateTime.now());
    return DateTimeRange(start: t, end: DateTime(t.year, t.month, t.day + 6));
  }

  DateTimeRange get _month {
    final t = dateOnly(DateTime.now());
    return DateTimeRange(
      start: DateTime(t.year, t.month, 1),
      end: DateTime(t.year, t.month + 1, 0),
    );
  }

  bool _is(DateTimeRange preset) =>
      _range != null && _range!.start == preset.start && _range!.end == preset.end;

  bool get _custom =>
      _range != null && !_is(_today) && !_is(_next7) && !_is(_month);

  Future<void> _pickCustom() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null && mounted) setState(() => _range = picked);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final customLabel = _custom
        ? '${Fmt.shortDate(_range!.start)} – ${Fmt.shortDate(_range!.end)}'
        : 'Personalizado';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Filtros',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton(onPressed: _reset, child: const Text('Limpar')),
            ],
          ),
          _label('Prioridade'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in Priority.values)
                FilterChip(
                  label: Text(p.label),
                  avatar: Icon(Icons.flag_rounded, size: 16, color: p.color),
                  selected: _priorities.contains(p),
                  onSelected: (v) => setState(() {
                    v ? _priorities.add(p) : _priorities.remove(p);
                  }),
                ),
            ],
          ),
          _label('Status'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _status == null && !_overdue,
                onSelected: (_) => setState(() {
                  _status = null;
                  _overdue = false;
                }),
              ),
              for (final s in TaskStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: _status == s,
                  onSelected: (_) => setState(() {
                    _status = s;
                    _overdue = false;
                  }),
                ),
              ChoiceChip(
                label: const Text('Atrasadas'),
                selected: _overdue,
                onSelected: (_) => setState(() {
                  _overdue = true;
                  _status = null;
                }),
              ),
            ],
          ),
          _label('Categoria'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: _categoryId == null,
                onSelected: (_) => setState(() => _categoryId = null),
              ),
              for (final cat in c.categories)
                ChoiceChip(
                  label: Text(cat.name),
                  avatar: Icon(cat.icon, size: 16, color: cat.color),
                  selected: _categoryId == cat.id,
                  onSelected: (_) => setState(() => _categoryId = cat.id),
                ),
            ],
          ),
          if (c.projects.isNotEmpty) ...[
            _label('Projeto'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _projectId == null,
                  onSelected: (_) => setState(() => _projectId = null),
                ),
                for (final p in c.projects)
                  ChoiceChip(
                    label: Text(p.name),
                    avatar: Icon(Icons.folder_outlined, size: 16, color: p.color),
                    selected: _projectId == p.id,
                    onSelected: (_) => setState(() => _projectId = p.id),
                  ),
              ],
            ),
          ],
          _label('Data'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Qualquer'),
                selected: _range == null,
                onSelected: (_) => setState(() => _range = null),
              ),
              ChoiceChip(
                label: const Text('Hoje'),
                selected: _is(_today),
                onSelected: (_) => setState(() => _range = _today),
              ),
              ChoiceChip(
                label: const Text('Próximos 7 dias'),
                selected: _is(_next7),
                onSelected: (_) => setState(() => _range = _next7),
              ),
              ChoiceChip(
                label: const Text('Este mês'),
                selected: _is(_month),
                onSelected: (_) => setState(() => _range = _month),
              ),
              ChoiceChip(
                label: Text(customLabel),
                selected: _custom,
                onSelected: (_) => _pickCustom(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(
                context,
                TaskFilter(
                  priorities: _priorities,
                  categoryId: _categoryId,
                  projectId: _projectId,
                  status: _status,
                  overdueOnly: _overdue,
                  range: _range,
                ),
              ),
              child: const Text('Aplicar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
