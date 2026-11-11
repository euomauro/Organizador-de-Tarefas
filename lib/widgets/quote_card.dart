import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/quote_controller.dart';
import '../core/constants.dart';
import '../core/utils.dart';

/// Cartão "Motivação do dia" alimentado pela API ZenQuotes.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final q = context.watch<QuoteController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [kPurple, kBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (q.state) {
            QuoteState.loading => const SizedBox(
                key: ValueKey('loading'),
                height: 96,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            QuoteState.error => _ErrorContent(
                key: const ValueKey('error'),
                message: q.error ?? 'Não foi possível carregar a frase.',
                onRetry: q.loadToday,
              ),
            QuoteState.success => _QuoteContent(
                key: ValueKey(q.quote?.text),
                controller: q,
              ),
          },
        ),
      ),
    );
  }
}

class _QuoteContent extends StatelessWidget {
  const _QuoteContent({super.key, required this.controller});

  final QuoteController controller;

  @override
  Widget build(BuildContext context) {
    final quote = controller.quote!;
    final text = Theme.of(context).textTheme;
    const onGradient = Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_quote_rounded, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              'Motivação do dia',
              style: text.labelLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          quote.text,
          style: text.titleMedium?.copyWith(color: onGradient, height: 1.4),
        ),
        if (quote.author.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('— ${quote.author}',
              style: text.bodyMedium?.copyWith(color: Colors.white70)),
        ],
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: onGradient),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: '"${quote.text}" — ${quote.author}'),
                );
                if (context.mounted) showSnack(context, 'Frase copiada');
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copiar'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: onGradient),
              onPressed: controller.isRefreshing
                  ? null
                  : () async {
                      final error = await controller.loadRandom();
                      if (error != null && context.mounted) {
                        showSnack(context, error, error: true);
                      }
                    },
              icon: controller.isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.autorenew_rounded, size: 18),
              label: const Text('Nova frase'),
            ),
          ],
        ),
        Text(
          'Frases por ZenQuotes.io',
          style: text.bodySmall?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.white70),
            const SizedBox(width: 8),
            Text('Motivação do dia',
                style: text.labelLarge?.copyWith(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 12),
        Text(message, style: text.bodyMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 8),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}
