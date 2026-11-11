import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/task.dart';
import '../widgets/responsive_body.dart';
import 'organization_screen.dart';

/// Formulário para criar ou editar uma tarefa.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task, this.initialDate});

  final Task? task;
  final DateTime? initialDate;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _date;
  TimeOfDay? _time;
  late Priority _priority;
  late TaskStatus _status;
  int? _categoryId;
  int? _projectId;
  late bool _favorite;
  bool _saving = false;
  String? _dateError;

  bool get _editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _date = t?.dueDate ?? dateOnly(widget.initialDate ?? DateTime.now());
    _time = t?.dueTime;
    _priority = t?.priority ?? Priority.medium;
    _status = t?.status ?? TaskStatus.pending;
    _categoryId = t?.categoryId;
    _projectId = t?.projectId;
    _favorite = t?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Data da tarefa',
    );
    if (picked != null && mounted) {
      setState(() {
        _date = dateOnly(picked);
        _dateError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: 'Horário',
    );
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
        _dateError = null;
      });
    }
  }

  String? _validateSchedule() {
    if (_editing) return null;
    final now = DateTime.now();
    if (_date.isBefore(dateOnly(now))) {
      return 'Escolha uma data de hoje em diante';
    }
    if (_time != null && isSameDay(_date, now)) {
      final when = DateTime(
          _date.year, _date.month, _date.day, _time!.hour, _time!.minute);
      if (when.isBefore(now)) return 'Esse horário já passou';
    }
    return null;
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    final scheduleError = _validateSchedule();
    setState(() => _dateError = scheduleError);
    if (!valid || scheduleError != null) return;

    setState(() => _saving = true);
    final base = widget.task;
    final task = Task(
      id: base?.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      dueDate: dateOnly(_date),
      dueTime: _time,
      priority: _priority,
      categoryId: _categoryId,
      projectId: _projectId,
      status: _status,
      isFavorite: _favorite,
      createdAt: base?.createdAt ?? DateTime.now(),
      completedAt: _status == TaskStatus.done
          ? (base?.completedAt ?? DateTime.now())
          : null,
    );

    final error = await context.read<TaskController>().saveTask(task);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    Navigator.pop(context, true);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Editar tarefa' : 'Nova tarefa')),
      body: ResponsiveBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              TextFormField(
                controller: _title,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: appInput(context,
                    label: 'Título', hint: 'O que precisa ser feito?', icon: Icons.title_rounded),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Informe um título';
                  if (value.length < 3) return 'Use pelo menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                maxLength: 500,
                maxLines: 4,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: appInput(context,
                    label: 'Descrição (opcional)',
                    icon: Icons.notes_rounded),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: appInput(context,
                          label: 'Data', icon: Icons.event_rounded)
                      .copyWith(errorText: _dateError),
                  child: Text(Fmt.longDate(_date)),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: appInput(context,
                          label: 'Horário (opcional)',
                          icon: Icons.schedule_rounded)
                      .copyWith(
                    suffixIcon: _time == null
                        ? null
                        : IconButton(
                            tooltip: 'Remover horário',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _time = null;
                              _dateError = null;
                            }),
                          ),
                  ),
                  child: Text(
                    _time == null ? 'Sem horário' : Fmt.time(_time!),
                    style: TextStyle(
                      color: _time == null ? cs.onSurfaceVariant : null,
                    ),
                  ),
                ),
              ),
              _label('Prioridade'),
              SegmentedButton<Priority>(
                showSelectedIcon: false,
                segments: [
                  for (final p in Priority.values)
                    ButtonSegment(value: p, label: Text(p.label)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              _label('Status'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in TaskStatus.values)
                    ChoiceChip(
                      label: Text(s.label),
                      avatar: Icon(s.icon, size: 18),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 10),
                      child: Text('Categoria',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const OrganizationScreen()),
                    ),
                    child: const Text('Gerenciar'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Nenhuma'),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                  for (final cat in c.categories)
                    ChoiceChip(
                      label: Text(cat.name),
                      avatar: Icon(cat.icon, size: 18, color: cat.color),
                      selected: _categoryId == cat.id,
                      onSelected: (_) => setState(() => _categoryId = cat.id),
                    ),
                ],
              ),
              _label('Projeto'),
              if (c.projects.isEmpty)
                Text(
                  'Nenhum projeto criado. Use "Gerenciar" para criar projetos.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('Nenhum'),
                      selected: _projectId == null,
                      onSelected: (_) => setState(() => _projectId = null),
                    ),
                    for (final p in c.projects)
                      ChoiceChip(
                        label: Text(p.name),
                        avatar:
                            Icon(Icons.folder_outlined, size: 18, color: p.color),
                        selected: _projectId == p.id,
                        onSelected: (_) => setState(() => _projectId = p.id),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorita'),
                secondary: Icon(
                  _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _favorite ? const Color(0xFFF59E0B) : null,
                ),
                value: _favorite,
                onChanged: (v) => setState(() => _favorite = v),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_editing ? 'Salvar alterações' : 'Criar tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
