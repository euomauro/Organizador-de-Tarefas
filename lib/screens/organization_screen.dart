import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/project.dart';
import '../models/task_category.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_actions.dart';
import 'task_list_screen.dart';

/// Gerenciamento de categorias e projetos.
class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool get _onCategories => _tabs.index == 0;

  Future<void> _edit({TaskCategory? category, Project? project}) async {
    final isCategory = _onCategories;
    final result = await showDialog<_EditorResult>(
      context: context,
      builder: (_) => _EditorDialog(
        title: isCategory
            ? (category == null ? 'Nova categoria' : 'Editar categoria')
            : (project == null ? 'Novo projeto' : 'Editar projeto'),
        initialName: category?.name ?? project?.name ?? '',
        initialColor: category?.colorValue ?? project?.colorValue ?? kPalette.first.toARGB32(),
        initialIcon: isCategory ? (category?.iconIndex ?? 0) : null,
      ),
    );
    if (result == null || !mounted) return;
    final controller = context.read<TaskController>();
    final error = isCategory
        ? await controller.saveCategory(TaskCategory(
            id: category?.id,
            name: result.name,
            colorValue: result.color,
            iconIndex: result.icon,
          ))
        : await controller.saveProject(Project(
            id: project?.id,
            name: result.name,
            colorValue: result.color,
          ));
    if (error != null && mounted) showSnack(context, error, error: true);
  }

  Future<void> _deleteCategory(TaskCategory cat) async {
    final ok = await confirmDelete(
      context,
      title: 'Excluir categoria?',
      message: 'As tarefas de "${cat.name}" não serão excluídas, apenas ficarão sem categoria.',
    );
    if (!ok || !mounted) return;
    final error = await context.read<TaskController>().deleteCategory(cat.id!);
    if (error != null && mounted) showSnack(context, error, error: true);
  }

  Future<void> _deleteProject(Project p) async {
    final ok = await confirmDelete(
      context,
      title: 'Excluir projeto?',
      message: 'As tarefas de "${p.name}" não serão excluídas, apenas ficarão sem projeto.',
    );
    if (!ok || !mounted) return;
    final error = await context.read<TaskController>().deleteProject(p.id!);
    if (error != null && mounted) showSnack(context, error, error: true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias e projetos'),
        bottom: TabBar(
          controller: _tabs,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'Categorias'), Tab(text: 'Projetos')],
        ),
      ),
      body: ResponsiveBody(
        child: TabBarView(
          controller: _tabs,
          children: [
            _buildCategories(c),
            _buildProjects(c),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: Text(_onCategories ? 'Nova categoria' : 'Novo projeto'),
      ),
    );
  }

  Widget _buildCategories(TaskController c) {
    if (c.categories.isEmpty) {
      return const EmptyState(
        icon: Icons.label_outline_rounded,
        title: 'Sem categorias',
        message: 'Crie categorias para agrupar suas tarefas por assunto.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: c.categories.length,
      itemBuilder: (context, i) {
        final cat = c.categories[i];
        final n = c.countForCategory(cat.id!);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ItemTile(
            leading: cat.icon,
            color: cat.color,
            name: cat.name,
            count: n,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskListScreen(
                  title: cat.name,
                  emptyMessage: 'Nenhuma tarefa nesta categoria.',
                  selector: (x) => x.tasksOfCategory(cat.id!),
                ),
              ),
            ),
            onEdit: () => _edit(category: cat),
            onDelete: () => _deleteCategory(cat),
          ),
        );
      },
    );
  }

  Widget _buildProjects(TaskController c) {
    if (c.projects.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'Sem projetos',
        message: 'Crie projetos para organizar tarefas relacionadas a um mesmo objetivo.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: c.projects.length,
      itemBuilder: (context, i) {
        final p = c.projects[i];
        final n = c.countForProject(p.id!);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ItemTile(
            leading: Icons.folder_outlined,
            color: p.color,
            name: p.name,
            count: n,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TaskListScreen(
                  title: p.name,
                  emptyMessage: 'Nenhuma tarefa neste projeto.',
                  selector: (x) => x.tasksOfProject(p.id!),
                ),
              ),
            ),
            onEdit: () => _edit(project: p),
            onDelete: () => _deleteProject(p),
          ),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.leading,
    required this.color,
    required this.name,
    required this.count,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final IconData leading;
  final Color color;
  final String name;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(leading, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleMedium),
                Text(
                  '$count ${count == 1 ? 'tarefa' : 'tarefas'}',
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditorResult {
  const _EditorResult(this.name, this.color, this.icon);
  final String name;
  final int color;
  final int icon;
}

class _EditorDialog extends StatefulWidget {
  const _EditorDialog({
    required this.title,
    required this.initialName,
    required this.initialColor,
    this.initialIcon,
  });

  final String title;
  final String initialName;
  final int initialColor;
  final int? initialIcon;

  @override
  State<_EditorDialog> createState() => _EditorDialogState();
}

class _EditorDialogState extends State<_EditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  late int _color = widget.initialColor;
  late int _icon = widget.initialIcon ?? 0;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _EditorResult(_name.text.trim(), _color, _icon));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showIcons = widget.initialIcon != null;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                autofocus: true,
                maxLength: 24,
                textCapitalization: TextCapitalization.sentences,
                decoration: appInput(context, label: 'Nome'),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Informe um nome';
                  if (value.length < 2) return 'Use pelo menos 2 caracteres';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text('Cor', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in kPalette)
                    GestureDetector(
                      onTap: () => setState(() => _color = color.toARGB32()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _color == color.toARGB32()
                              ? Border.all(color: cs.onSurface, width: 3)
                              : null,
                        ),
                        child: _color == color.toARGB32()
                            ? const Icon(Icons.check_rounded,
                                size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              if (showIcons) ...[
                const SizedBox(height: 18),
                Text('Ícone', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < kCategoryIcons.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _icon = i),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _icon == i
                                ? Color(_color).withValues(alpha: 0.18)
                                : null,
                            border: Border.all(
                              color: _icon == i
                                  ? Color(_color)
                                  : cs.outlineVariant,
                            ),
                          ),
                          child: Icon(
                            kCategoryIcons[i],
                            color: _icon == i ? Color(_color) : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
