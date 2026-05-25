import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class OnboardingAnimation extends StatelessWidget {
  const OnboardingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: RiveAnimation.network(
        'https://public.rive.app/community/runtime-files/3086-6383-learning.riv',
        fit: BoxFit.contain,
      ),
    );
  }
}
