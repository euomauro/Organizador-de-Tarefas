import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/task_controller.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../widgets/app_card.dart';
import '../widgets/responsive_body.dart';
import '../widgets/task_actions.dart';
import 'onboarding_screen.dart';
import 'organization_screen.dart';

/// Ajustes: aparência, organização, dados e informações do app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCompleted(BuildContext context) async {
    final controller = context.read<TaskController>();
    final n = controller.doneCount;
    if (n == 0) {
      showSnack(context, 'Não há tarefas concluídas para remover.');
      return;
    }
    final ok = await confirmDelete(
      context,
      title: 'Remover concluídas?',
      message: '$n ${n == 1 ? 'tarefa concluída será excluída' : 'tarefas concluídas serão excluídas'} permanentemente.',
    );
    if (!ok || !context.mounted) return;
    final error = await controller.clearCompleted();
    if (!context.mounted) return;
    showSnack(context, error ?? 'Tarefas concluídas removidas.',
        error: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 10),
          child: Text(title,
              style: text.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
        );

    Widget tile(IconData icon, String title, String subtitle, VoidCallback onTap) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),
                      Text(subtitle,
                          style: text.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ResponsiveBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            section('Aparência'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema', style: text.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.system, label: Text('Sistema')),
                        ButtonSegment(
                            value: ThemeMode.light, label: Text('Claro')),
                        ButtonSegment(
                            value: ThemeMode.dark, label: Text('Escuro')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (s) =>
                          settings.setThemeMode(s.first),
                    ),
                  ),
                ],
              ),
            ),
            section('Organização'),
            tile(
              Icons.folder_special_outlined,
              'Categorias e projetos',
              'Crie, edite e exclua',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const OrganizationScreen()),
              ),
            ),
            section('Dados'),
            tile(
              Icons.cleaning_services_outlined,
              'Remover tarefas concluídas',
              'Libera espaço e deixa a lista mais limpa',
              () => _clearCompleted(context),
            ),
            tile(
              Icons.slideshow_rounded,
              'Rever introdução',
              'Veja novamente a apresentação do app',
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const OnboardingScreen(fromSettings: true)),
              ),
            ),
            section('Sobre'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppConstants.appName} ${AppConstants.version}',
                      style: text.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Seus dados ficam salvos apenas neste aparelho (SQLite).\n'
                    'Frases motivacionais fornecidas pela API pública ZenQuotes (zenquotes.io).',
                    style: text.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
