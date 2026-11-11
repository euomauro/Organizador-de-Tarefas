import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../core/constants.dart';
import 'main_shell.dart';

class _Page {
  const _Page(this.icon, this.title, this.message);
  final IconData icon;
  final String title;
  final String message;
}

/// Introdução exibida no primeiro acesso.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.fromSettings = false});

  /// Quando aberta pelos Ajustes, apenas fecha ao terminar.
  final bool fromSettings;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _Page(
      Icons.checklist_rounded,
      'Tudo em um só lugar',
      'Crie tarefas com data, horário, prioridade e categoria, e acompanhe cada uma até a conclusão.',
    ),
    _Page(
      Icons.calendar_month_rounded,
      'Planeje seus dias',
      'Veja suas atividades no calendário, foque no que é para hoje e nunca perca um prazo.',
    ),
    _Page(
      Icons.insights_rounded,
      'Acompanhe sua evolução',
      'Gráficos de produtividade mostram o quanto você já conquistou e ajudam a manter o ritmo.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    await context.read<SettingsController>().completeOnboarding();
    if (!mounted) return;
    if (widget.fromSettings) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: Text(_isLast ? '' : 'Pular'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [kPurple, kBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(p.icon, size: 84, color: Colors.white),
                            ),
                            const SizedBox(height: 44),
                            Text(p.title,
                                style: text.headlineSmall,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 14),
                            Text(
                              p.message,
                              textAlign: TextAlign.center,
                              style: text.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? cs.primary
                              : cs.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_isLast ? 'Começar' : 'Próximo'),
                    ),
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
