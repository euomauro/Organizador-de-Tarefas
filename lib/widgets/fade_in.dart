import 'package:flutter/material.dart';

/// Animação sutil de entrada (fade + deslocamento), escalonada por [index].
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final step = index > 8 ? 8 : index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + step * 50),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: child),
      ),
      child: child,
    );
  }
}
