import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeIn({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 500.ms, delay: delay.ms)
        .slideY(begin: 0.15, duration: 450.ms);
  }
}
